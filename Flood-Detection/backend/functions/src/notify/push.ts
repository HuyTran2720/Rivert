import { onDocumentUpdated } from "firebase-functions/firestore";
import { RiskState } from "../types/models";

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
 * TODO: fetch devices/{fcmToken} docs and actually send via FCM.
 * Stubbed with a log until device registration is built.
 *
 * @param {string} siteId Which site changed.
 * @param {RiskState} before Previous riskState.
 * @param {RiskState} after New riskState.
 * @return {Promise<void>} Resolves once the (stub) send completes.
 */
async function sendRiskTransitionPush(
  siteId: string,
  before: RiskState,
  after: RiskState,
): Promise<void> {
  console.log(`push (stub): ${siteId} ${before} → ${after}`);
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

    if (!before || !after) return;
    if (!shouldNotify(before, after)) return;

    await sendRiskTransitionPush(event.params.siteId, before, after);
  },
);
