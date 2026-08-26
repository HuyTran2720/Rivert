import { Reading, Calibration, LevelPoint } from "../types/models";
import { isPlausible } from "./validity";

/**
 * @param {number} rawDistanceMM Sensor reading.
 * @param {Calibration} cal Site calibration.
 * @return {number} Water height above the channel bed, mm.
 */
export function levelMM(rawDistanceMM: number, cal: Calibration): number {
  return cal.d_bed - (rawDistanceMM - cal.sensor_offset_mm);
}

/**
 * Bed to street. With street-relative calibration d_bed IS the full
 * channel depth, but naming it makes the level-fraction maths legible.
 *
 * @param {Calibration} cal Site calibration.
 * @return {number} Channel depth, mm.
 */
export function channelDepthMM(cal: Calibration): number {
  return cal.d_bed;
}

/**
 * Where the water sits in the channel, 0 (bed) to 1 (street). Derived
 * from freeboard rather than levelMM so it stays consistent with the
 * danger rung, which is freeboard-based.
 *
 * @param {number} freeboardBankMM Freeboard to street level.
 * @param {Calibration} cal Site calibration.
 * @return {number} Fraction of channel depth filled.
 */
export function levelFraction(
  freeboardBankMM: number,
  cal: Calibration,
): number {
  const depth = channelDepthMM(cal);
  if (!(depth > 0)) return 0; // uncalibrated site: never escalate on noise
  return 1 - freeboardBankMM / depth;
}

/**
 * @param {Reading[]} readings Raw readings, any order.
 * @param {Calibration} cal Site calibration.
 * @return {LevelPoint[]} Usable points, oldest first.
 */
export function toLevelPoints(
  readings: Reading[],
  cal: Calibration,
): LevelPoint[] {
  return readings
    .filter((r) => isPlausible(r, cal))
    .map((r) => ({ at: r.timestamp, levelMM: levelMM(r.rawDistanceMM, cal) }))
    .sort((a, b) => a.at.getTime() - b.at.getTime());
}
