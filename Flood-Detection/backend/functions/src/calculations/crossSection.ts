import { Calibration } from "../types/models";

/**
 * Climb time. Below the bench the channel holds a constant width
 * (w_bottom). Above the bench the walls slope outward on a straight
 * grade — width increases linearly from (w_bottom + w_bench) at the
 * bench up to w_top at the bank. The trapezoidal average of those two
 * endpoints is the exact integral of a linear width function.
 *
 * @param {number} narrowMM Distance to climb inside the channel.
 * @param {number} wideMM Distance to climb above the benches.
 * @param {number} rateMMPerMin Rise rate measured in the channel.
 * @param {Calibration} cal Site calibration.
 * @return {number} Minutes, or Infinity if not rising.
 */
export function travelMinutes(
  narrowMM: number,
  wideMM: number,
  rateMMPerMin: number,
  cal: Calibration,
): number {
  if (rateMMPerMin <= 0) return Infinity;

  const narrowMin = Math.max(0, narrowMM) / rateMMPerMin;

  // Q is constant; the measured rate reflects width w_bottom.
  const q = cal.w_bottom * rateMMPerMin;
  const widthAtBench = cal.w_bottom + cal.w_bench;
  const avgWideWidth = (widthAtBench + cal.w_top) / 2;
  const wideMin = q > 0 ?
    (Math.max(0, wideMM) * avgWideWidth) / q :
    Infinity;

  return narrowMin + wideMin;
}
