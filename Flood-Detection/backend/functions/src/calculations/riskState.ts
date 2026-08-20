import { RiskState, Staleness, MinuteRange } from "../types/models";
import { DANGER_WITHIN_MIN, CAUTION_WITHIN_MIN } from "../config";

export interface RiskInput {
  staleness: Staleness;
  freeboardBenchMM: number;
  timeToBankMin: MinuteRange | null;
  bankConfirmed: boolean;
  haveRate: boolean;
}

/**
 * The ladder, top down. Deliberately cannot see rainfall or tide.
 *
 * @param {RiskInput} input The measured facts.
 * @return {RiskState} The classification.
 */
export function classifyRisk(input: RiskInput): RiskState {
  if (input.staleness === "noData") return "unknown";
  if (!input.haveRate) return "unknown";

  // Water is over the bank now, confirmed twice.
  if (input.bankConfirmed) return "danger";

  const soonest = input.timeToBankMin?.lower ?? null;

  if (soonest !== null && soonest < DANGER_WITHIN_MIN) return "danger";

  if (input.freeboardBenchMM <= 0) return "caution";
  if (soonest !== null && soonest < CAUTION_WITHIN_MIN) return "caution";

  return "normal";
}
