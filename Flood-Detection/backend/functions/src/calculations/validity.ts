import { Reading, Calibration } from "../types/models";
import {
  PLAUSIBILITY_UPPER_MARGIN_MM,
  PLAUSIBILITY_LOWER_MARGIN_MM,
} from "../config";

/**
 * @param {Reading} r The reading to check.
 * @param {Calibration} cal Site calibration.
 * @return {boolean} True if the reading is geometrically possible.
 */
export function isPlausible(r: Reading, cal: Calibration): boolean {
  if (r.rawDistanceMM - cal.sensor_offset_mm >
      cal.d_bed + PLAUSIBILITY_UPPER_MARGIN_MM) {
    return false;
  }
  if (r.rawDistanceMM < cal.sensor_offset_mm - PLAUSIBILITY_LOWER_MARGIN_MM) {
    return false;
  }
  return true;
}
