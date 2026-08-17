import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { getFirestore, Timestamp, FieldValue } from "firebase-admin/firestore";

admin.initializeApp();
const db = getFirestore();

interface Reading {
  deviceId: string;
  timestamp: string;
  rawDistanceMM: number;
}

function isValidReading(r: unknown): r is Reading {
  if (typeof r !== "object" || r === null) return false;
  const x = r as Record<string, unknown>;
  return (
    typeof x.deviceId === "string" && x.deviceId.length > 0 &&
    typeof x.timestamp === "string" &&
    !isNaN(Date.parse(x.timestamp)) &&
    typeof x.rawDistanceMM === "number"
  );
}

export const ingest = onRequest(
  { region: "asia-southeast2" },
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
      res.status(400).json({ error: "empty batch" });
      return;
    }

    // Shape validation only. A physically odd VALUE still gets stored —
    // plausibility filtering happens at calculation time, because
    // discarding weird readings here destroys the evidence we'd need
    // to diagnose a misbehaving sensor.
    const valid: Reading[] = [];
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
      res.status(400).json({ error: "no valid readings", rejected: rejected.length });
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
    console.log(`stored ${valid.length} from ${last.deviceId} | ${last.rawDistanceMM}mm`);

    // TODO: recompute state from the last 30 min, write state/legian-01,
    //       push if riskState changed.

    res.json({ ok: true, accepted: valid.length, rejected: rejected.length });
  }
);

// ! TESTING PURPOSES
export const ping = onRequest(
  { region: "asia-southeast2" },
  async (req, res) => {
    if (req.get("x-device-secret") !== process.env.DEVICE_SECRET) {
      res.status(401).send("unauthorized");
      return;
    }
    const doc = await db.doc("sites/legian-01").get();
    res.json({ ok: true, site: doc.data() });
  }
);