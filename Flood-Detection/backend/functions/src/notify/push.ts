import { onDocumentUpdated } from "firebase-functions/firestore";
import { MinuteRange, RiskState } from "../types/models";
import { getMessaging } from "firebase-admin/messaging";
import { db } from "../db/firestore";

const MESSAGE_FOR: Record<RiskState, { title: string; body: string }> = {
  normal: {
    title: "All Clear",
    body: "Water is within normal levels at Legian.",
  },
  caution: {
    title: "CAUTION",
    body: "Higher flood risk is expected in the Legian river ",
  },
  danger: {
    title: "DANGER",
    body: "The Legian river has overflowed, AVOID this area!",
  },
  unknown: {
    title: "Sensor Offline",
    body: "No recent data from the Legian sensor.",
  },
};

/**
 * @param {RiskState} before riskState before the update.
 * @param {RiskState} after riskState after the update.
 * @return {boolean} True only on an actual change of value — watch to
 * watch must NOT fire, or the operator gets paged every minute during a
 * storm and mutes the app permanently.
 */
export function shouldNotify(before: RiskState, after: RiskState): boolean {
  return before !== after;
}

/**
 * @param {string} siteId Which site changed.
 * @param {RiskState} before Previous riskState.
 * @param {RiskState} after New riskState.
 * @param {MinuteRange | null} timeToBankMin Projected minutes to
 * overspill, appended to the caution body when present.
 * @return {Promise<void>} Resolves once the send attempt completes.
 */
async function sendRiskTransitionPush(
  siteId: string,
  before: RiskState,
  after: RiskState,
  timeToBankMin: MinuteRange | null,
): Promise<void> {
  const devicesSnap = await db.collection("devices").get();
  const tokens = devicesSnap.docs.map((d) => d.id);

  if (tokens.length === 0) {
    console.log(`push: no registered devices — skipping ${before} → ${after}`);
    return;
  }

  const { title, body } = MESSAGE_FOR[after];
  const finalBody = after === "caution" && timeToBankMin ?
    `${body}${timeToBankMin.lower}–${timeToBankMin.upper} minutes.` :
    `${body}.`;

  const result = await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title, body: finalBody },
    data: { siteId, riskState: after },
  });

  console.log(
    `push: ${result.successCount}/${tokens.length} sent for ` +
    `${siteId} ${before} → ${after}`,
  );
  // TODO follow-up: prune tokens whose result came back "not-registered"
  // or "invalid-argument" so devices/ doesn't accumulate dead entries.
}

// Firestore trigger, not a scheduled poll: fires exactly once per
// state/{siteId} write, and hands us before/after for free — no need
// for ingest or the watchdog to separately track "what was riskState
// last time".
export const checkRiskAndNotify = onDocumentUpdated(
  "state/{siteId}",
  async (event) => {
    const before = event.data?.before.data()?.riskState as
      RiskState | undefined;
    const after = event.data?.after.data()?.riskState as
      RiskState | undefined;
    const timeToBankMin = (event.data?.after.data()?.timeToBankMin ??
      null) as MinuteRange | null;

    if (!before || !after) return;
    if (!shouldNotify(before, after)) return;
    if (after === "unknown") return;

    await sendRiskTransitionPush(
      event.params.siteId, before, after, timeToBankMin,
    );
  },
);
