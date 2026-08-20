import { getFirestore } from "firebase-admin/firestore";
import { staleness } from "./calc";

/**
 * updates the staleness in every state document for each site
 */
export async function runWatchDog(): Promise<void> {
    const now = new Date();
    const db = getFirestore();
    const snap = db.collection("state").get();

    for (const doc of (await snap).docs) {
        const data = doc.data();

        const latestReadingAt: Date = data.latestReadingAt?.toDate?.();
        if (!latestReadingAt)
            continue;

        const currentStaleness = staleness(latestReadingAt, now)
        if (currentStaleness === data.staleness) // don't update if staleness is the same
            continue;

        const update: Record<string, unknown> = {
            staleness: currentStaleness,
            computedAt: now,
        };

        if (currentStaleness === "noData") {
            update.riskState = "unknown";
        }

        await doc.ref.set(update, { merge: true });
        console.log(`watchdog: state/${doc.id} staleness → ${currentStaleness}`);
    }
}