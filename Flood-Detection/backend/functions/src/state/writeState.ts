import { Timestamp } from "firebase-admin/firestore";
import { db } from "../db/firestore";
import { Reading, Calibration } from "../types/models";
import { RATE_WINDOW_MIN, RECOMPUTE_INTERVAL_MS } from "../config";
import { computeSiteState } from "./recompute";

/**
 * Reads the previous state, applies the 30s recompute gate, and — if
 * due — fetches calibration + the reading window, recomputes, and
 * overwrites state/{siteId}. Raw readings are stored separately by
 * ingest/writeReadings.ts regardless of what this returns.
 *
 * @param {string} siteId Which site.
 * @param {Date} now Current time.
 * @return {Promise<boolean>} True if a recompute actually happened.
 */
export async function recomputeAndWriteState(
  siteId: string,
  now: Date,
): Promise<boolean> {
  const stateRef = db.doc(`state/${siteId}`);
  const prevStateSnap = await stateRef.get();
  const prevState = prevStateSnap.exists ? prevStateSnap.data() : null;

  // Raw is stored separately regardless; the expensive window query +
  // calc + state write only runs at most every 30s, even though the
  // device posts every 10s.
  const lastComputedAt = prevState?.computedAt?.toDate?.() ?? null;
  const dueForRecompute =
    !lastComputedAt ||
    (now.getTime() - lastComputedAt.getTime()) >= RECOMPUTE_INTERVAL_MS;

  if (!dueForRecompute) return false;

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
    return false;
  }

  const cal = siteSnap.data() as Calibration;
  if (cal.calibrated === undefined) cal.calibrated = false;
  if (cal.sensor_offset_mm === undefined) cal.sensor_offset_mm = 0;

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
    return false;
  }

  // merge: weather is written separately by refreshWeather. A plain
  // set() would delete it.
  await stateRef.set(newState, { merge: true });
  console.log(
    `state/${siteId} → ${newState.riskState} (level ${newState.levelMM}mm)`,
  );

  return true;
}
