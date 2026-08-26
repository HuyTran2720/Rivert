import { RiskState, Staleness, MinuteRange } from "../types/models";
import {
  DANGER_WITHIN_MIN,
  CAUTION_WITHIN_MIN,
  CAUTION_RAISE_FRACTION,
  CAUTION_CLEAR_FRACTION,
  CAUTION_LEVEL_FLOOR_FRACTION,
  CAUTION_DWELL_SEC,
} from "../config";

export interface RiskInput {
  staleness: Staleness;
  timeToBankMin: MinuteRange | null;
  freeboardBankMM: number;
  haveRate: boolean;
  /** Where the water sits in the channel: 0 = bed, 1 = street. */
  levelFraction: number;
  /** A rise big enough and clean enough to act on — magnitude above the
   * sensor noise floor, measured at the PESSIMISTIC edge of the rate
   * band, through a window linear enough to trust. See recompute.ts. */
  rising: boolean;
  /** What was published last time, or null on a cold start. */
  prevRiskState: RiskState | null;
  /** Seconds the previous state has been held. Gates the level rung
   * only, so flapping is damped without delaying a real fast rise. */
  heldForSec: number;
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
  if (input.freeboardBankMM <= 0) return "danger";

  // Positional floor. A channel this full warrants a warning even with
  // no rate at all, so it sits ABOVE the haveRate gate: it is the rung
  // that covers cold start, a stalled rise, and a blocked culvert —
  // every case where the height is alarming but the model is silent.
  if (input.levelFraction >= CAUTION_LEVEL_FLOOR_FRACTION) return "caution";

  if (!input.haveRate) return "unknown";

  const soonest = input.timeToBankMin?.lower ?? null;

  // Projection rungs. Deliberately NOT dwell-gated: when the model can
  // stand behind a countdown this short, delaying the badge to damp
  // flapping would cost lead time on exactly the events that matter.
  if (soonest !== null && soonest < DANGER_WITHIN_MIN) return "danger";
  if (soonest !== null && soonest < CAUTION_WITHIN_MIN) return "caution";

  // Level rung, with hysteresis. Raise and clear use DIFFERENT
  // thresholds, and neither may move until the current state has been
  // held for CAUTION_DWELL_SEC — otherwise water sitting on the line
  // toggles the badge every recompute and pushes on each toggle.
  const dwellMet = input.heldForSec >= CAUTION_DWELL_SEC;

  if (input.prevRiskState === "caution") {
    const mayClear =
      input.levelFraction < CAUTION_CLEAR_FRACTION &&
      !input.rising &&
      dwellMet;
    return mayClear ? "normal" : "caution";
  }

  const mayRaise =
    input.levelFraction >= CAUTION_RAISE_FRACTION &&
    input.rising &&
    dwellMet;

  return mayRaise ? "caution" : "normal";
}
