// Tuning constants. Demo values now; field values in brackets, to be
// swapped in once real data justifies them.

export const MS_PER_MIN = 60 * 1000;
export const MS_PER_HOUR = 60 * MS_PER_MIN;

// The fit window and its minimum sample count move together. The rig
// posts once every 10s (6 readings/min), so a 2 min window holds 12
// readings and the 8-reading minimum is reached about 80s after the
// first post. Theil-Sen needs a decent sample to be worth its
// robustness — three points is not a trend.
//
// 2 rather than 3 is a demo choice: on a ~4 min climb, a 3 min window
// smooths over three quarters of the event and the countdown visibly
// lags at the end. 2 trades a tighter fit for a countdown that tracks.
export const RATE_WINDOW_MIN = 2; // [15]
export const MIN_READINGS_FOR_RATE = 8; // [20]

// An honest forecast reaches about three times as far as the trajectory
// it was fitted from. Derived rather than hand-set so the horizon can
// never quietly drift away from the window that justifies it.
//
// NOTE: this is no longer a publish gate. A projection further out than
// this used to be discarded entirely, which meant timeToBankMin was
// null for every rise slower than ~30 mm/min and the field looked
// permanently broken. It is kept as the honest-confidence marker: past
// this many minutes the number is an extrapolation well beyond its fit
// window, and the UI should present it as soft.
export const PROJECTION_HORIZON_MULTIPLE = 3;
export const MAX_PROJECTION_MIN =
  PROJECTION_HORIZON_MULTIPLE * RATE_WINDOW_MIN;

// Ceiling on the PUBLISHED upper bound only. When the slow edge of the
// rate band sits at or below zero the slow-side projection is Infinity,
// which Firestore cannot store — so it is reported as this instead.
// Deliberately far beyond any decision threshold: nothing in
// classifyRisk or leadTime reads `upper`, so this only ever affects
// display, never a badge.
export const MAX_PUBLISHED_UPPER_MIN = 1440; // 24h

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
export const DANGER_WITHIN_MIN = 0.5; // [10]
export const CAUTION_WITHIN_MIN = 1.5; // [30]

// ---- Level-based caution rung -------------------------------------
// Fires on HEIGHT + SUSTAINED RISE together, replacing the old bench
// crossing. Expressed as a fraction of channel depth (0 = bed, 1 =
// street) so it reads the same at any site regardless of geometry.

// Raise at half depth. Clearing is anchored to the positional floor
// below, not to the raise threshold: caution is mostly raised by that
// floor rung, and clearing at 45% meant a channel draining normally
// held the badge for thirty points of depth after it was already safe.
// Water under the floor and not rising is not a warning.
export const CAUTION_RAISE_FRACTION = 0.50;
export const CAUTION_CLEAR_FRACTION = 0.75;

// Positional floor. A channel this full is worth a warning even with no
// rate at all — a stalled rise, a blocked culvert, or the first 80s of
// an event before MIN_READINGS_FOR_RATE is met. Checked BEFORE the
// haveRate gate for exactly that reason.
export const CAUTION_LEVEL_FLOOR_FRACTION = 0.75;

// The minimum rise that counts as rising. NOT a physical constant — it
// is the sensor's noise floor, and it is a PLACEHOLDER until measured:
// run the rig on still water, take the distribution of fitted rates,
// and set this above its 95th percentile. Too low and a spring tide
// filling the channel slowly reads as a flood; that false positive is
// the entire reason this rung takes a rate at all.
export const CAUTION_RISE_MMPERMIN = 3; // [TO BE MEASURED]

// How long the height+rise condition must hold before the badge moves.
// Applies to the LEVEL rung only — the projection rungs above it are
// ungated, so a genuinely fast rise still escalates immediately.
export const CAUTION_DWELL_SEC = 2; // [90]

// At one post per 10s: stale after 3 missed, noData after 9.
export const STALE_AFTER_MIN = 0.5; // [2]
export const NO_DATA_AFTER_MIN = 1.5; // [15]

// Sized for the scaled rig, where the whole channel is 205mm deep. The
// lower margin must stay loose enough that water at the tank rim — which
// reads 110mm — is still plausible, or the filter would throw away
// readings during the overspill we are demonstrating.
export const PLAUSIBILITY_UPPER_MARGIN_MM = 30; // [100]
export const PLAUSIBILITY_LOWER_MARGIN_MM = 50; // [500]

// Posts arrive every 10s; anything below that means every post
// recomputes. At 30_000 only every third one did, and the dashboard
// updated 8 times across a 4 minute demo.
export const RECOMPUTE_INTERVAL_MS = 5_000; // [30_000]

export const WEATHER_SLOT_HOURS = 3;
export const WEATHER_HORIZON_HOURS = 6;
export const WEATHER_FETCH_TIMEOUT_MS = 8000;
export const WEATHER_STALE_AFTER_MIN = 180;
export const WEATHER_NO_DATA_AFTER_MIN = 720;
// How many 3-hour slots ride along on the state document. Index 0 is
// the current slot, so 5 covers now plus the next four — what the UI
// strip shows. Aggregates are still computed from the FULL forecast;
// only this published list is truncated.
export const WEATHER_FORECAST_SLOTS = 5;

export const WEATHER_SITE_ID = "legian-01";
