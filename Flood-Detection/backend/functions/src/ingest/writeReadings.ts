import { Timestamp, FieldValue } from "firebase-admin/firestore";
import { db } from "../db/firestore";
import { WireReading } from "./schema";

/**
 * Idempotent: doc id is deviceId_timestamp, so a resend after a
 * network drop overwrites rather than duplicating.
 *
 * @param {WireReading[]} valid Shape-validated readings to store.
 * @return {Promise<void>} Resolves once the batch commits.
 */
export async function writeReadings(valid: WireReading[]): Promise<void> {
  const batch = db.batch();
  for (const r of valid) {
    const id = `${r.deviceId}_${r.timestamp}`.replace(/[/.]/g, "_");
    batch.set(db.doc(`readings/${id}`), {
      ...r,
      timestamp: Timestamp.fromDate(new Date(r.timestamp)),
      serverReceivedAt: FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
}
