import {onRequest} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import {getFirestore, Timestamp, FieldValue} from "firebase-admin/firestore";
import {computeSiteState, RATE_WINDOW_MIN, Reading, Calibration} from "./calc";
import {fetchWeather} from "./weather";

admin.initializeApp();
const db = getFirestore();

interface WireReading {
  deviceId: string;
  timestamp: string;
  rawDistanceMM: number;
}

/**
 * @param {unknown} r Anything that arrived in the request body.
 * @return {boolean} True if it has the shape of a WireReading.
 */
function isValidReading(r: unknown): r is WireReading {
  if (typeof r !== "object" || r === null) return false;
  const x = r as Record<string, unknown>;
  return (
    typeof x.deviceId === "string" && x.deviceId.length > 0 &&
    typeof x.timestamp === "string" &&
    !isNaN(Date.parse(x.timestamp)) &&
    typeof x.rawDistanceMM === "number"
  );
}

const RECOMPUTE_INTERVAL_MS = 30_000;

export const ingest = onRequest(
  {region: "asia-southeast2"},
  async (req, res) => {
    // Fail loudly if config is missing — otherwise undefined !== undefined
    // is false and a request with NO header would be accepted.
    const expected = process.env.DEVICE_SECRET;
    if (!expected) {
      console.error("DEVICE_SECRET not set — check functions/.env");
      res.status(500).send("server misconfigured");
      return;
    }

    if (req.get("x-device-secret") !== expected) {
      console.warn("rejected: bad or missing secret");
      res.status(401).send("unauthorized");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).send("POST only");
      return;
    }

    const incoming = Array.isArray(req.body) ? req.body : [req.body];

    if (incoming.length === 0) {
      res.status(400).json({error: "empty batch"});
      return;
    }

    // Shape validation only. A physically odd VALUE still gets stored —
    // plausibility filtering happens at calculation time, because
    // discarding weird readings here destroys the evidence we'd need
    // to diagnose a misbehaving sensor.
    const valid: WireReading[] = [];
    const rejected: unknown[] = [];
    for (const r of incoming) {
      if (isValidReading(r)) valid.push(r);
      else rejected.push(r);
    }

    if (rejected.length > 0) {
      console.warn(`rejected ${rejected.length} malformed:`,
        JSON.stringify(rejected));
    }

    if (valid.length === 0) {
      res.status(400).json({
        error: "no valid readings",
        rejected: rejected.length,
      });
      return;
    }

    // Idempotent: doc id is deviceId_timestamp, so a resend after a
    // network drop overwrites rather than duplicating.
    const batch = db.batch();
    for (const r of valid) {
      const id = `${r.deviceId}_${r.timestamp}`.replace(/[/.]/g, "_");
      batch.set(db.doc(`readings/${id}`), { // batch stored into /readings
        ...r,
        timestamp: Timestamp.fromDate(new Date(r.timestamp)),
        serverReceivedAt: FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    const last = valid[valid.length - 1];
    console.log(
      `stored ${valid.length} from ${last.deviceId} | ` +
      `${last.rawDistanceMM}mm`,
    );

    const siteId = last.deviceId;
    const stateRef = db.doc(`state/${siteId}`);
    const prevStateSnap = await stateRef.get();
    const prevState = prevStateSnap.exists ? prevStateSnap.data() : null;

    // Raw is stored above regardless; the expensive window query + calc +
    // state write only runs at most every 30s, even though the device
    // posts every 10s.
    const lastComputedAt = prevState?.computedAt?.toDate?.() ?? null;
    const dueForRecompute =
      !lastComputedAt ||
      (Date.now() - lastComputedAt.getTime()) >= RECOMPUTE_INTERVAL_MS;

    if (!dueForRecompute) {
      res.json({
        ok: true,
        accepted: valid.length,
        rejected: rejected.length,
        recomputed: false,
      });
      return;
    }

    const now = new Date();
    const windowStart = new Date(now.getTime() - RATE_WINDOW_MIN * 60_000);

    const [siteSnap, windowSnap] = await Promise.all([
      db.doc(`sites/${siteId}`).get(),
      db.collection("readings")
        .where("deviceId", "==", siteId)
        .where("timestamp", ">=", Timestamp.fromDate(windowStart))
        .orderBy("timestamp")
        .get(),
    ]);

    if (!siteSnap.exists) {
      console.error(`sites/${siteId} missing — skipping recompute`);
      res.json({
        ok: true,
        accepted: valid.length,
        rejected: rejected.length,
        recomputed: false,
      });
      return;
    }

    const cal = siteSnap.data() as Calibration;
    if (cal.calibrated === undefined) cal.calibrated = false;
    const readings: Reading[] = windowSnap.docs.map((d) => {
      const data = d.data();
      return {
        deviceId: data.deviceId,
        timestamp: (data.timestamp as Timestamp).toDate(),
        rawDistanceMM: data.rawDistanceMM,
      };
    });

    const newState = computeSiteState(siteId, readings, cal, now);

    if (!newState) {
      console.warn(
        `no plausible readings in window for ${siteId} — ` +
        "state not overwritten",
      );
      res.json({
        ok: true,
        accepted: valid.length,
        rejected: rejected.length,
        recomputed: false,
      });
      return;
    }

    // merge: the weather field on this document is written by
    // refreshWeather, not by us. A plain set() would delete it.
    await stateRef.set(newState, {merge: true});
    console.log(
      `state/${siteId} → ${newState.riskState} ` +
      `(level ${newState.levelMM}mm)`,
    );

    res.json({
      ok: true,
      accepted: valid.length,
      rejected: rejected.length,
      recomputed: true,
    });
  }
);

// The BMKG url in weather.ts is hardcoded to Legian's village code, so
// this fetch is only valid for this one site.
const WEATHER_SITE_ID = "legian-01";

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
      .set({weather}, {merge: true});

    console.log(
      `weather/${WEATHER_SITE_ID} → ${weather.nowDesc}, ` +
      `${weather.precipRateMMPerHour}mm/h, ` +
      `${weather.precipProbabilityNext6hPct}% next 6h`,
    );
  },
);

// ! TESTING PURPOSES
export const ping = onRequest(
  {region: "asia-southeast2"},
  async (req, res) => {
    if (req.get("x-device-secret") !== process.env.DEVICE_SECRET) {
      res.status(401).send("unauthorized");
      return;
    }
    const doc = await db.doc("sites/legian-01").get();
    res.json({ok: true, site: doc.data()});
  }
);
