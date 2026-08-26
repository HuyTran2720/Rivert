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
  /** Theil-Sen slope: the median of every pairwise slope in the window.
   * Robust to the false echoes an ultrasonic sensor throws off debris
   * and ripples — it tolerates roughly 29% bad points, where a least
   * squares fit is skewed by one. */
  mmPerMin: number;
  /** How well a straight line describes this window, on [0,1], measured
   * from median absolute residual so a lone spike cannot veto it. Gates
   * whether a countdown may be published at all. */
  fitQuality: number;
  /** Empirical band from the pairwise-slope distribution, not a
   * parametric interval. These are the rates the projection is actually
   * run at. */
  fastestMMPerMin: number;
  slowestMMPerMin: number;
  /** How many readings the fit saw. */
  n: number;
}

/** What the app should actually display. Deliberately coarse: a bucket
 * that is occasionally wrong reads as caution, where "14 minutes" that
 * is wrong reads as a broken app. Boundaries are DANGER_WITHIN_MIN and
 * CAUTION_WITHIN_MIN, so this can never contradict riskState. */
export type LeadTime =
  | "overspilling"
  | "imminent"
  | "soon"
  | "rising"
  | "risingUnclear"
  | "notRising"
  | "unknown";

/** The single document the app reads. Weather is merged in separately
 * by refreshWeather. */
export interface SiteState {
  siteId: string;
  levelMM: number;
  rateMMPerMin: number | null;
  freeboardMM: number;
  /** Raw projected range. Present for completeness; prefer leadTime for
   * anything user-facing. Null unless the rise is sustained AND the fit
   * clears MIN_R2_FOR_PROJECTION. */
  timeToBankMin: MinuteRange | null;
  /** The display bucket. This is the field the app should render. */
  leadTime: LeadTime;
  riskState: RiskState;
  /** When riskState last changed. Persisted so the dwell gate survives
   * across invocations — recompute is stateless otherwise. */
  riskStateSince: Date;
  staleness: Staleness;
  latestReadingAt: Date;
  computedAt: Date;
  calibrated: boolean;
}
