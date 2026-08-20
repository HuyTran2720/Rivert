import { Reading, Calibration, LevelPoint } from "../types/models";
import { isPlausible } from "./validity";

/**
 * @param {number} rawDistanceMM Sensor reading.
 * @param {Calibration} cal Site calibration.
 * @return {number} Water height above the channel bed, mm.
 */
export function levelMM(rawDistanceMM: number, cal: Calibration): number {
  return cal.d_bed - rawDistanceMM;
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
