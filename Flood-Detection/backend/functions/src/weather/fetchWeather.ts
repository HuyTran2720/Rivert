// Weather context for the state document. Display only — nothing here
// ever reaches classifyRisk.
//
// BMKG is the primary source (official, 3-hourly, Legian village code).
// Open-Meteo supplies the one thing BMKG has no field for: rain
// probability. If Open-Meteo fails we still publish weather, just with
// null probabilities. If BMKG fails we publish nothing and the caller
// keeps whatever it cached last.

import { onSchedule } from "firebase-functions/v2/scheduler";
import { onRequest } from "firebase-functions/v2/https";
import { type Staleness } from "../types/models";
import { db } from "../db/firestore";
import {
  WEATHER_SLOT_HOURS,
  WEATHER_HORIZON_HOURS,
  WEATHER_FETCH_TIMEOUT_MS,
  WEATHER_STALE_AFTER_MIN,
  WEATHER_NO_DATA_AFTER_MIN,
  WEATHER_SITE_ID,
  MS_PER_MIN,
  MS_PER_HOUR,
} from "../config";
import { BMKG_URL, WeatherSlot, parseBMKG } from "./bmkg";
import { OPEN_METEO_URL, ProbPoint, parseOpenMeteo } from "./openMeteo";

/** What gets merged into the state document. */
export interface Weather {
  nowDesc: string;
  nowIconURL: string;
  nowTempC: number;
  precipRateMMPerHour: number;
  /** Chance of rain this hour. Null if Open-Meteo was unreachable. */
  precipProbabilityNowPct: number | null;
  /** Peak chance of rain across the next 6h. */
  precipProbabilityNext6hPct: number | null;
  next6hTotalMM: number;
  /** Searched across the FULL forecast, not just the 6h horizon. */
  rainStartsAt: Date | null;
  /** Consecutive wet slots x 3h. Resolution is 3 hours, not minutes. */
  rainDurationHours: number | null;
  /**
   * When this forecast was pulled. Deliberately the ONLY freshness
   * field: a stored staleness would be stamped once and then keep
   * claiming "fresh" forever if the scheduler died. Derive it from
   * this instead, with weatherStaleness().
   */
  fetchedAt: Date;
}

/**
 * @param {number} x The value to round.
 * @return {number} x rounded to one decimal place.
 */
function round1(x: number): number {
  return Math.round(x * 10) / 10;
}

/**
 * @param {WeatherSlot[]} slots Slots, oldest first.
 * @param {Date} now Current time.
 * @return {WeatherSlot | undefined} The slot covering now.
 */
function currentSlot(
  slots: WeatherSlot[],
  now: Date,
): WeatherSlot | undefined {
  const t = now.getTime();
  const slotMs = WEATHER_SLOT_HOURS * MS_PER_HOUR;
  const covering = slots.find(
    (s) => s.at.getTime() <= t && t < s.at.getTime() + slotMs,
  );
  if (covering) return covering;
  // Forecast starts in the future, or has run out behind us.
  return slots.find((s) => s.at.getTime() > t) ?? slots[slots.length - 1];
}

/**
 * @param {ProbPoint[]} probs Probability points.
 * @param {Date} now Current time.
 * @return {number | null} Probability at the nearest hour, or null.
 */
function probNearest(probs: ProbPoint[], now: Date): number | null {
  if (probs.length === 0) return null;
  let best = probs[0];
  for (const p of probs) {
    const gap = Math.abs(p.at.getTime() - now.getTime());
    if (gap < Math.abs(best.at.getTime() - now.getTime())) {
      best = p;
    }
  }
  return best.probabilityPct;
}

/**
 * @param {ProbPoint[]} probs Probability points.
 * @param {number} fromMs Window start.
 * @param {number} toMs Window end.
 * @return {number | null} Highest probability in the window, or null.
 */
function probPeak(
  probs: ProbPoint[],
  fromMs: number,
  toMs: number,
): number | null {
  const inWindow = probs.filter(
    (p) => p.at.getTime() >= fromMs && p.at.getTime() <= toMs,
  );
  if (inWindow.length === 0) return null;
  return Math.max(...inWindow.map((p) => p.probabilityPct));
}

/**
 * @param {Date} fetchedAt When the forecast was last pulled.
 * @param {Date} now Current time.
 * @return {Staleness} fresh, stale, or noData.
 */
export function weatherStaleness(fetchedAt: Date, now: Date): Staleness {
  const ageMin = (now.getTime() - fetchedAt.getTime()) / MS_PER_MIN;
  if (ageMin > WEATHER_NO_DATA_AFTER_MIN) return "noData";
  if (ageMin > WEATHER_STALE_AFTER_MIN) return "stale";
  return "fresh";
}

/**
 * Build the published weather object. Pure, so it is testable without
 * touching the network.
 *
 * @param {WeatherSlot[]} slots Parsed BMKG slots.
 * @param {ProbPoint[]} probs Parsed Open-Meteo points. May be empty.
 * @param {Date} fetchedAt When the forecast was pulled.
 * @param {Date} now Current time.
 * @return {Weather | null} The summary, or null if nothing usable.
 */
export function summarize(
  slots: WeatherSlot[],
  probs: ProbPoint[],
  fetchedAt: Date,
  now: Date,
): Weather | null {
  const current = currentSlot(slots, now);
  if (!current) return null;

  const nowMs = now.getTime();
  const horizonEnd = nowMs + WEATHER_HORIZON_HOURS * MS_PER_HOUR;
  const slotMs = WEATHER_SLOT_HOURS * MS_PER_HOUR;

  // Any slot that overlaps the horizon at all counts toward the total.
  let next6hTotalMM = 0;
  for (const s of slots) {
    const start = s.at.getTime();
    if (start + slotMs > nowMs && start < horizonEnd) {
      next6hTotalMM += s.precipMM;
    }
  }

  const ahead = slots.filter((s) => s.at.getTime() >= current.at.getTime());
  const startIdx = ahead.findIndex((s) => s.precipMM > 0);

  let rainStartsAt: Date | null = null;
  let rainDurationHours: number | null = null;
  if (startIdx >= 0) {
    rainStartsAt = ahead[startIdx].at;
    let wet = 0;
    for (let i = startIdx; i < ahead.length && ahead[i].precipMM > 0; i++) {
      wet++;
    }
    rainDurationHours = wet * WEATHER_SLOT_HOURS;
  }

  return {
    nowDesc: current.description,
    nowIconURL: current.iconURL,
    nowTempC: current.tempC,
    precipRateMMPerHour: round1(current.precipMM / WEATHER_SLOT_HOURS),
    precipProbabilityNowPct: probNearest(probs, now),
    precipProbabilityNext6hPct: probPeak(probs, nowMs, horizonEnd),
    next6hTotalMM: round1(next6hTotalMM),
    rainStartsAt,
    rainDurationHours,
    fetchedAt,
  };
}

/**
 * @param {string} url The endpoint to GET.
 * @return {Promise<unknown>} The decoded JSON body.
 */
async function getJSON(url: string): Promise<unknown> {
  const res = await fetch(url, {
    signal: AbortSignal.timeout(WEATHER_FETCH_TIMEOUT_MS),
  });
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
  return res.json();
}

/**
 * Pull both forecasts and summarise them.
 *
 * Never throws. A dead weather API must not be able to break ingest —
 * the flood warning does not depend on knowing the weather.
 *
 * @param {Date} now Current time.
 * @return {Promise<Weather | null>} The summary, or null on failure.
 */
export async function fetchWeather(now: Date): Promise<Weather | null> {
  const [bmkg, om] = await Promise.allSettled([
    getJSON(BMKG_URL),
    getJSON(OPEN_METEO_URL),
  ]);

  if (bmkg.status === "rejected") {
    console.error("BMKG unreachable:", bmkg.reason);
    return null;
  }
  if (om.status === "rejected") {
    console.warn("Open-Meteo unreachable; probability omitted");
  }

  const slots = parseBMKG(bmkg.value);
  const probs = om.status === "fulfilled" ? parseOpenMeteo(om.value) : [];

  if (slots.length === 0) {
    console.error("BMKG returned no parseable slots");
    return null;
  }

  return summarize(slots, probs, now, now);
}

// Hourly, because that is as often as the upstream forecasts actually
// change: BMKG re-runs its model roughly every 6h, Open-Meteo hourly.
export const refreshWeather = onSchedule(
  {
    schedule: "every 1 hours",
    region: "asia-southeast2",
    timeZone: "Asia/Makassar",
  },
  async () => {
    const weather = await fetchWeather(new Date());

    // fetchWeather never throws; null means the upstream API failed.
    // Keeping yesterday's forecast beats blanking the field.
    if (!weather) {
      console.warn("weather refresh produced nothing — keeping last copy");
      return;
    }

    // merge: this function owns the weather field and nothing else on
    // the document. ingest owns all the rest.
    await db
      .doc(`state/${WEATHER_SITE_ID}`)
      .set({ weather }, { merge: true });

    console.log(
      `weather/${WEATHER_SITE_ID} → ${weather.nowDesc}, ` +
      `${weather.precipRateMMPerHour}mm/h, ` +
      `${weather.precipProbabilityNext6hPct}% next 6h`,
    );
  },
);

export const refreshWeatherHTTP = onRequest(
  { region: "asia-southeast2" },
  async (req, res) => {
    if (req.get("x-device-secret") !== process.env.DEVICE_SECRET) {
      res.status(401).send("unauthorized");
      return;
    }

    const weather = await fetchWeather(new Date());

    // fetchWeather never throws; null means the upstream API failed.
    // Keeping yesterday's forecast beats blanking the field.
    if (!weather) {
      res.status(502).send("API fetch failed.");
      return;
    }

    // merge: this function owns the weather field and nothing else on
    // the document. ingest owns all the rest.
    await db
      .doc(`state/${WEATHER_SITE_ID}`)
      .set({ weather }, { merge: true });
    res.json({ ok: true });
  },
);
