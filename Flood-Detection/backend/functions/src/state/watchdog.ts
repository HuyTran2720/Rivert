import { onSchedule } from "firebase-functions/v2/scheduler";
import { onRequest } from "firebase-functions/v2/https";
import { db } from "../db/firestore";
import { staleness } from "../calculations/staleness";

/**
 * Updates the staleness (and, if it's gone silent, riskState) in every
 * site's state document. Runs independent of ingest, since ingest is
 * only triggered by data ARRIVING — nothing notices data STOPPING.
 */
export async function runWatchDog(): Promise<void> {
  const now = new Date();
  const snap = await db.collection("state").get();

  for (const doc of snap.docs) {
    const data = doc.data();

    const latestReadingAt: Date = data.latestReadingAt?.toDate?.();
    if (!latestReadingAt) continue;

    const currentStaleness = staleness(latestReadingAt, now);
    if (currentStaleness === data.staleness) continue; // already accurate

    const update: Record<string, unknown> = {
      staleness: currentStaleness,
      computedAt: now,
    };

    // Only the noData direction is safe to guess riskState for — it's
    // the one case classifyRisk decides from staleness alone. Recovery
    // to "fresh"/"stale" doesn't tell us the real riskState (needs
    // freeboard/rate data this function doesn't have) — leave riskState
    // as-is and let the next ingest recompute correct it.
    if (currentStaleness === "noData") {
      update.riskState = "unknown";
    }

    await doc.ref.set(update, { merge: true });
    console.log(`watchdog: state/${doc.id} staleness → ${currentStaleness}`);
  }
}

export const staleWatchDog = onSchedule(
  {
    schedule: "every 5 minutes",
    region: "asia-southeast2",
    timeZone: "Asia/Makassar",
  },
  async () => {
    await runWatchDog();
  },
);

// the emulator can't fire onSchedule locally, so we need to poke this
// by hand during development. Same auth guard as ping.
// still useful for testing even if we deploy
export const staleWatchdogHttp = onRequest(
  { region: "asia-southeast2" },
  async (req, res) => {
    if (req.get("x-device-secret") !== process.env.DEVICE_SECRET) {
      res.status(401).send("unauthorized");
      return;
    }
    await runWatchDog();
    res.json({ ok: true });
  },
);
