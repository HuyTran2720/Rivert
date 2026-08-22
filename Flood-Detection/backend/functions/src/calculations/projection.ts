import { Rate, Calibration, MinuteRange } from "../types/models";
import {
  MAX_PROJECTION_MIN,
  MIN_FIT_QUALITY_FOR_PROJECTION,
} from "../config";
import { travelMinutes } from "./crossSection";

/**
 * @param {number} x The value to round.
 * @return {number} x rounded to one decimal place.
 */
function round1(x: number): number {
  return Math.round(x * 10) / 10;
}

/**
 * Project with the fastest and slowest believable rate, taken from the
 * observed spread of pairwise slopes rather than a normal assumption.
 *
 * @param {number} narrowMM Distance to climb inside the channel.
 * @param {number} wideMM Distance to climb above the benches.
 * @param {Rate} rate The fitted rate of rise.
 * @param {Calibration} cal Site calibration.
 * @return {MinuteRange | null} The range, or null if not projectable.
 */
function projectRange(
  narrowMM: number,
  wideMM: number,
  rate: Rate,
  cal: Calibration,
): MinuteRange | null {
  if (rate.mmPerMin <= 0) return null;

  // A window this poorly described by a line is not something to
  // extrapolate from. The rise still gets reported; only the countdown
  // is withheld.
  if (rate.fitQuality < MIN_FIT_QUALITY_FOR_PROJECTION) return null;

  const lower = travelMinutes(narrowMM, wideMM, rate.fastestMMPerMin, cal);
  const upper = travelMinutes(narrowMM, wideMM, rate.slowestMMPerMin, cal);

  if (!Number.isFinite(lower) || lower > MAX_PROJECTION_MIN) return null;

  const lowerMin = Math.max(0, round1(lower));
  const upperMin = Math.min(
    MAX_PROJECTION_MIN,
    Number.isFinite(upper) ? round1(upper) : MAX_PROJECTION_MIN,
  );

  return { lower: lowerMin, upper: Math.max(lowerMin, upperMin) };
}

/**
 * @param {number} fbBenchMM Freeboard to the benches.
 * @param {number} fbBankMM Freeboard to the bank.
 * @param {Rate | null} rate Fitted rate of rise.
 * @param {Calibration} cal Site calibration.
 * @return {MinuteRange | null} Minutes until overspill, or null.
 */
export function timeToBank(
  fbBenchMM: number,
  fbBankMM: number,
  rate: Rate | null,
  cal: Calibration,
): MinuteRange | null {
  if (!rate) return null;
  if (fbBankMM <= 0) return null;

  const narrowMM = Math.max(0, fbBenchMM);
  const wideMM = fbBankMM - narrowMM;

  return projectRange(narrowMM, wideMM, rate, cal);
}
