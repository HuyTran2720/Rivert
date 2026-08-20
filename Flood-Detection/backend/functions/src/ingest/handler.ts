import { onRequest } from "firebase-functions/v2/https";
import { isValidReading, WireReading } from "./schema";
import { writeReadings } from "./writeReadings";
import { recomputeAndWriteState } from "../state/writeState";

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

    await writeReadings(valid);

    const last = valid[valid.length - 1];
    console.log(
      `stored ${valid.length} from ${last.deviceId} | ` +
      `${last.rawDistanceMM}mm`,
    );

    const recomputed = await recomputeAndWriteState(
      last.deviceId,
      new Date(),
    );

    res.json({
      ok: true,
      accepted: valid.length,
      rejected: rejected.length,
      recomputed,
    });
  },
);
