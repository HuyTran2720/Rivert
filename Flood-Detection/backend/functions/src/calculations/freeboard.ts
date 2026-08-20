import { Calibration } from "../types/models";

// Sign convention: distances are measured DOWN, so a bigger
// rawDistanceMM means the water is farther away — i.e. lower.
// Freeboard is "how much room is left", so it must be raw minus the
// threshold's distance, not the other way round. rawDistanceMM is
// sensor-relative but d_bench/d_bed are street-level-relative, so
// sensor_offset_mm converts between the two before comparing. Get any
// of this backwards and every <= 0 danger/caution check fires exactly
// when it shouldn't.

/**
 * Not published. Needed by classifyRisk and by timeToBank's channel split.
 *
 * @param {number} rawDistanceMM Sensor reading.
 * @param {Calibration} cal Site calibration.
 * @return {number} Freeboard to the benches, mm. Negative once passed.
 */
export function freeboardBenchMM(
  rawDistanceMM: number,
  cal: Calibration,
): number {
  return rawDistanceMM - cal.d_bench;
}

/**
 * Street level is the actual overspill threshold — the doc's "bank" was
 * always this, never a separate elevation. If the sensor sat exactly at
 * street level, freeboard would just be rawDistanceMM; sensor_offset_mm
 * corrects for the sensor sitting slightly above it.
 *
 * @param {number} rawDistanceMM Sensor reading.
 * @param {Calibration} cal Site calibration.
 * @return {number} Freeboard to street level, mm. Negative = overspilled.
 */
export function freeboardBankMM(
  rawDistanceMM: number,
  cal: Calibration,
): number {
  return rawDistanceMM - cal.sensor_offset_mm;
}
