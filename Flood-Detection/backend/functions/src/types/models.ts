export interface Reading {
  deviceId: string;
  timestamp: Date;
  rawDistanceMM: number;
}

/** Tape-measured site geometry. d_bed and d_bench are measured DOWN
 * FROM STREET LEVEL (the top of the channel), not from the sensor —
 * sensor_offset_mm is the separate, small gap between the sensor and
 * street level. d_bank is not a distance at all; see below. */
export interface Calibration {
  d_bed: number;
  d_bench: number;
  // NOT a threshold — this is d_bed - d_bench, the low-flow channel's
  // own depth. Unused in calculations below; kept for reference until
  // we find it a job.
  d_bank: number;
  w_bottom: number;
  w_bench: number;
  w_top: number;
  // Sensor height above street level. 0 = mounted exactly at street
  // level.
  sensor_offset_mm: number;
  calibrated: boolean;
}

export interface MinuteRange {
  lower: number;
  upper: number;
}

export type RiskState = "normal" | "caution" | "danger" | "unknown";

export type Staleness = "fresh" | "stale" | "noData";

export interface LevelPoint {
  at: Date;
  levelMM: number;
}

export interface Rate {
  mmPerMin: number;
  r2: number;
  seMMPerMin: number;
}

/** The single document the app reads. Weather is merged in separately
 * by refreshWeather. */
export interface SiteState {
  siteId: string;
  levelMM: number;
  rateMMPerMin: number | null;
  freeboardMM: number;
  timeToBankMin: MinuteRange | null;
  riskState: RiskState;
  staleness: Staleness;
  latestReadingAt: Date;
  computedAt: Date;
  calibrated: boolean;
}
