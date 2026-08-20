// Tuning constants. Demo values now; field values in brackets, to be
// swapped in once real data justifies them.

export const MS_PER_MIN = 60 * 1000;
export const MS_PER_HOUR = 60 * MS_PER_MIN;

export const RATE_WINDOW_MIN = 1; // [15]
export const MIN_READINGS_FOR_RATE = 3;
export const MAX_PROJECTION_MIN = 10; // [240]
export const DANGER_WITHIN_MIN = 1; // [30]
export const CAUTION_WITHIN_MIN = 4; // [120]
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
