import { MinuteRange, Rate, LeadTime } from "../types/models";
import { DANGER_WITHIN_MIN, CAUTION_WITHIN_MIN } from "../config";

export interface LeadTimeInput {
  freeboardBankMM: number;
  timeToBankMin: MinuteRange | null;
  rate: Rate | null;
  /** Did the previous recompute also see a rise? */
  sustained: boolean;
}

/**
 * The bucket the app displays instead of a number of minutes.
 *
 * Boundaries are DANGER_WITHIN_MIN and CAUTION_WITHIN_MIN — the same
 * two constants classifyRisk uses — so the bucket and the risk state
 * can never tell the user two different stories.
 *
 * @param {LeadTimeInput} input The measured facts.
 * @return {LeadTime} The bucket.
 */
export function leadTime(input: LeadTimeInput): LeadTime {
  if (input.freeboardBankMM <= 0) return "overspilling";
  if (!input.rate) return "unknown";
  if (input.rate.mmPerMin <= 0) return "notRising";

  // Rising, but we cannot yet stand behind a countdown: either the rise
  // has not repeated, or the fit was too poor to extrapolate.
  if (!input.sustained || !input.timeToBankMin) return "risingUnclear";

  if (input.timeToBankMin.lower < DANGER_WITHIN_MIN) return "imminent";
  if (input.timeToBankMin.lower < CAUTION_WITHIN_MIN) return "soon";
  return "rising";
}
