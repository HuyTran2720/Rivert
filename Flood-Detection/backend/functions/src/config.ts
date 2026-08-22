// Tuning constants. Demo values now; field values in brackets, to be
// swapped in once real data justifies them.

export const MS_PER_MIN = 60 * 1000;
export const MS_PER_HOUR = 60 * MS_PER_MIN;

// The fit window and its minimum sample count move together: at the
// device's ~10s posting rate a 3 min window holds ~18 readings, so 8 is
// reachable about 80s after the first post. Theil-Sen needs a decent
// sample to be worth its robustness — three points is not a trend.
export const RATE_WINDOW_MIN = 3; // [15]
export const MIN_READINGS_FOR_RATE = 8; // [20]

// An honest forecast reaches about three times as far as the trajectory
// it was fitted from. Derived rather than hand-set so the horizon can
// never quietly drift away from the window that justifies it.
export const PROJECTION_HORIZON_MULTIPLE = 3;
export const MAX_PROJECTION_MIN =
  PROJECTION_HORIZON_MULTIPLE * RATE_WINDOW_MIN;

// Percentiles of the pairwise-slope distribution that become the
// fastest/slowest believable rate. Empirical, so no normality assumed.
export const RATE_BAND_LOWER_PCT = 10;
export const RATE_BAND_UPPER_PCT = 90;

// Floor on the band half-width, as a fraction of the median slope. A
// quantised sensor on a steady rise easily produces collinear points,
// and without this the band collapses to zero and we would publish a
// single number dressed up as a range — maximum false confidence at
// exactly the moment we know least.
export const RATE_BAND_FLOOR_FRACTION = 0.15;

// Below this, the window is not linear enough to extrapolate from. The
// rise is still reported; only the countdown is withheld.
//
// Measured robustly (see rate.ts) rather than as a classic r-squared:
// one false echo must not be able to veto a forecast, or a sensor that
// blips once a minute would never produce one at all.
export const MIN_FIT_QUALITY_FOR_PROJECTION = 0.7;

// Both thresholds must stay under MAX_PROJECTION_MIN or they can never
// fire — nothing beyond the horizon is ever published.
export const DANGER_WITHIN_MIN = 1; // [10]
export const CAUTION_WITHIN_MIN = 5; // [30]

export const STALE_AFTER_MIN = 0.5; // [2]
export const NO_DATA_AFTER_MIN = 2; // [15]
export const PLAUSIBILITY_UPPER_MARGIN_MM = 100;
export const PLAUSIBILITY_LOWER_MARGIN_MM = 500;
export const RECOMPUTE_INTERVAL_MS = 30_000;

export const WEATHER_SLOT_HOURS = 3;
export const WEATHER_HORIZON_HOURS = 6;
export const WEATHER_FETCH_TIMEOUT_MS = 8000;
export const WEATHER_STALE_AFTER_MIN = 180;
export const WEATHER_NO_DATA_AFTER_MIN = 720;
export const WEATHER_SITE_ID = "legian-01";
