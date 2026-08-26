import { RiskState, Staleness, MinuteRange } from "../types/models";
import { DANGER_WITHIN_MIN, CAUTION_WITHIN_MIN } from "../config";

export interface RiskInput {
  staleness: Staleness;
  freeboardBenchMM: number;
  timeToBankMin: MinuteRange | null;
  freeboardBankMM: number;
  haveRate: boolean;
}

/**
 * The ladder, top down. Deliberately cannot see rainfall or tide.
 *
 * @param {RiskInput} input The measured facts.
 * @return {RiskState} The classification.
 */
export function classifyRisk(input: RiskInput): RiskState {
  // Silence still outranks everything: stale news of a flood is not a
  // flood, and we cannot tell which we are looking at.
  if (input.staleness === "noData") return "unknown";

  // Water is over the street. A measured fact that needs no model, so
  // it is settled before the rate is consulted — otherwise a site that
  // has not yet collected MIN_READINGS_FOR_RATE samples reports an
  // active overspill as "unknown".
  //
  // A single reading is enough, deliberately. This used to require two
  // consecutive ones so a lone false echo could not trip danger, but at
  // the crossing itself timeToBank goes null (there is no freeboard
  // left to project through) and the first over-the-line reading then
  // fell through to the bench rung — dropping the badge from danger
  // back to caution for exactly one tick, mid-flood, and firing a
  // downgrade notification with it. Glitch protection belongs upstream
  // anyway: the device sends a median, and isPlausible screens the rest.
  if (input.freeboardBankMM <= 0) return "danger";

  if (!input.haveRate) return "unknown";

  const soonest = input.timeToBankMin?.lower ?? null;

  if (soonest !== null && soonest < DANGER_WITHIN_MIN) return "danger";

  if (input.freeboardBenchMM <= 0) return "caution";
  if (soonest !== null && soonest < CAUTION_WITHIN_MIN) return "caution";

  return "normal";
}
