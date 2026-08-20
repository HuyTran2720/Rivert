// Weather context for the state document. Display only — nothing here
// ever reaches classifyRisk.
//
// BMKG is the primary source (official, 3-hourly, Legian village code).
// Open-Meteo supplies the one thing BMKG has no field for: rain
// probability. If Open-Meteo fails we still publish weather, just with
// null probabilities. If BMKG fails we publish nothing and the caller
// keeps whatever it cached last.

import {type Staleness} from "./calc.js";

const BMKG_URL =
  "https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=51.03.01.1004";

const OPEN_METEO_URL =
  "https://api.open-meteo.com/v1/forecast" +
  "?latitude=-8.7038&longitude=115.1728" +
  "&hourly=precipitation_probability&forecast_days=2&timezone=UTC";

// BMKG publishes one row per 3 hours.
const SLOT_HOURS = 3;
// How far ahead the rollup looks.
const HORIZON_HOURS = 6;
const FETCH_TIMEOUT_MS = 8000;
// BMKG re-runs its model roughly every 6h; these are generous.
const WEATHER_STALE_AFTER_MIN = 180;
const WEATHER_NO_DATA_AFTER_MIN = 720;

const MS_PER_MIN = 60 * 1000;
const MS_PER_HOUR = 60 * MS_PER_MIN;

/** One parsed BMKG 3-hour forecast slot. */
export interface WeatherSlot {
  at: Date;
  tempC: number;
  /** Total precipitation across the whole 3h slot, mm. */
  precipMM: number;
  cloudPct: number;
  humidityPct: number;
  description: string;
}

/** One hourly rain-probability point from Open-Meteo. */
export interface ProbPoint {
  at: Date;
  probabilityPct: number;
}

/** What gets merged into the state document. */
export interface Weather {
  /** custom icon */
  nowDesc: string;
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

interface BmkgEntry {
  datetime?: unknown;
  t?: unknown;
  tp?: unknown;
  tcc?: unknown;
  hu?: unknown;
  weather_desc_en?: unknown;
}

interface BmkgResponse {
  data?: { cuaca?: BmkgEntry[][] }[];
}

interface OpenMeteoResponse {
  hourly?: {
    time?: unknown[];
    precipitation_probability?: unknown[];
  };
}

/**
 * @param {unknown} v Any value from an external payload.
 * @return {number} The number, or 0 if it was missing or not finite.
 */
function num(v: unknown): number {
  return typeof v === "number" && Number.isFinite(v) ? v : 0;
}

/**
 * @param {unknown} v Any value from an external payload.
 * @return {string} The string, or "" if it was missing.
 */
function str(v: unknown): string {
  return typeof v === "string" ? v : "";
}

/**
 * @param {number} x The value to round.
 * @return {number} x rounded to one decimal place.
 */
function round1(x: number): number {
  return Math.round(x * 10) / 10;
}

/**
 * Flatten BMKG's nested day groups into one sorted list.
 *
 * @param {unknown} raw The decoded BMKG response.
 * @return {WeatherSlot[]} Slots, oldest first. Empty if unparseable.
 */
export function parseBMKG(raw: unknown): WeatherSlot[] {
  const groups = (raw as BmkgResponse)?.data?.[0]?.cuaca;
  if (!Array.isArray(groups)) return [];

  const out: WeatherSlot[] = [];
  for (const group of groups) {
    if (!Array.isArray(group)) continue;
    for (const e of group) {
      const at = new Date(str(e?.datetime));
      if (Number.isNaN(at.getTime())) continue;
      out.push({
        at,
        tempC: num(e.t),
        precipMM: num(e.tp),
        cloudPct: num(e.tcc),
        humidityPct: num(e.hu),
        description: str(e.weather_desc_en),
      });
    }
  }
  return out.sort((a, b) => a.at.getTime() - b.at.getTime());
}

/**
 * Open-Meteo returns "2026-08-19T00:00" with no zone marker, which JS
 * parses as LOCAL time. Without the appended Z every point shifts.
 *
 * @param {unknown} raw The decoded Open-Meteo response.
 * @return {ProbPoint[]} Points, oldest first. Empty if unparseable.
 */
export function parseOpenMeteo(raw: unknown): ProbPoint[] {
  const hourly = (raw as OpenMeteoResponse)?.hourly;
  const times = hourly?.time;
  const probs = hourly?.precipitation_probability;
  if (!Array.isArray(times) || !Array.isArray(probs)) return [];

  const out: ProbPoint[] = [];
  for (let i = 0; i < times.length; i++) {
    const t = str(times[i]);
    if (t === "") continue;
    const iso = t.endsWith("Z") ? t : `${t}${t.length === 16 ? ":00" : ""}Z`;
    const at = new Date(iso);
    if (Number.isNaN(at.getTime())) continue;
    out.push({at, probabilityPct: num(probs[i])});
  }
  return out.sort((a, b) => a.at.getTime() - b.at.getTime());
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
  const slotMs = SLOT_HOURS * MS_PER_HOUR;
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
  const horizonEnd = nowMs + HORIZON_HOURS * MS_PER_HOUR;
  const slotMs = SLOT_HOURS * MS_PER_HOUR;

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
    rainDurationHours = wet * SLOT_HOURS;
  }

  return {
    nowDesc: current.description,
    nowTempC: current.tempC,
    precipRateMMPerHour: round1(current.precipMM / SLOT_HOURS),
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
    signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
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
