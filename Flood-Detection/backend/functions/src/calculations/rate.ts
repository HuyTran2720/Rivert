import { LevelPoint, Rate } from "../types/models";
import {
  MS_PER_MIN,
  MIN_READINGS_FOR_RATE,
  RATE_BAND_LOWER_PCT,
  RATE_BAND_UPPER_PCT,
  RATE_BAND_FLOOR_FRACTION,
} from "../config";

/**
 * Linear interpolation between order statistics.
 *
 * @param {number[]} sorted Values, ascending. Must not be empty.
 * @param {number} pct Percentile in [0,100].
 * @return {number} The interpolated percentile.
 */
function percentile(sorted: number[], pct: number): number {
  if (sorted.length === 1) return sorted[0];
  const idx = ((pct / 100) * (sorted.length - 1));
  const lo = Math.floor(idx);
  const hi = Math.ceil(idx);
  if (lo === hi) return sorted[lo];
  return sorted[lo] + (sorted[hi] - sorted[lo]) * (idx - lo);
}

/**
 * @param {number[]} sorted Values, ascending. Must not be empty.
 * @return {number} The median.
 */
function median(sorted: number[]): number {
  return percentile(sorted, 50);
}

/**
 * Theil-Sen slope through the window. Null (never 0) when there is not
 * enough data — an absent rate must never be reported as a rate of zero.
 *
 * Why not least squares: a single false echo skews an OLS slope badly,
 * and its standard error only measures scatter about the line, so three
 * collinear quantised readings produce a confident-looking interval of
 * zero width. The median of the pairwise slopes ignores a minority of
 * bad points, and the spread of that same distribution is the
 * uncertainty — measured, not assumed.
 *
 * @param {LevelPoint[]} points Level history, oldest first.
 * @param {number} windowMin How far back to look, in minutes.
 * @param {Date} now Current time.
 * @return {Rate | null} The fitted rate, or null.
 */
export function rateOfRise(
  points: LevelPoint[],
  windowMin: number,
  now: Date,
): Rate | null {
  const cutoff = now.getTime() - windowMin * MS_PER_MIN;
  const win = points.filter((p) => p.at.getTime() >= cutoff);
  if (win.length < MIN_READINGS_FOR_RATE) return null;

  // x in minutes since the first point, so the intercept and residuals
  // stay in a sane numeric range. Slopes are differences, so centring
  // leaves them untouched.
  const t0 = win[0].at.getTime();
  const xs = win.map((p) => (p.at.getTime() - t0) / MS_PER_MIN);
  const ys = win.map((p) => p.levelMM);
  const n = win.length;

  const slopes: number[] = [];
  for (let i = 0; i < n; i++) {
    for (let j = i + 1; j < n; j++) {
      const dx = xs[j] - xs[i];
      if (dx === 0) continue; // duplicate timestamps carry no slope
      slopes.push((ys[j] - ys[i]) / dx);
    }
  }
  if (slopes.length === 0) return null;
  slopes.sort((a, b) => a - b);

  const slope = median(slopes);

  // Theil-Sen intercept: the median of each point's implied intercept.
  const intercepts = xs
    .map((x, i) => ys[i] - slope * x)
    .sort((a, b) => a - b);
  const intercept = median(intercepts);

  // Fit quality, measured the same way the slope was: from medians, not
  // sums of squares. A classic r-squared squares its residuals, so the
  // single false echo that Theil-Sen just shrugged off would come
  // straight back and veto the forecast. The median absolute residual
  // ignores it too, and still collapses when the window is genuinely
  // curved or noisy — which is the thing worth refusing to extrapolate.
  const fitted = xs.map((x) => intercept + slope * x);
  const absRes = ys
    .map((y, i) => Math.abs(y - fitted[i]))
    .sort((a, b) => a - b);
  const yMedian = median([...ys].sort((a, b) => a - b));
  const absDev = ys
    .map((y) => Math.abs(y - yMedian))
    .sort((a, b) => a - b);

  const scale = median(absDev);
  const fitQuality =
    scale === 0 ? 1 : Math.max(0, Math.min(1, 1 - median(absRes) / scale));

  let slowestMMPerMin = percentile(slopes, RATE_BAND_LOWER_PCT);
  let fastestMMPerMin = percentile(slopes, RATE_BAND_UPPER_PCT);

  // Never claim more precision than the sensor can support.
  const floor = Math.abs(slope) * RATE_BAND_FLOOR_FRACTION;
  if (fastestMMPerMin - slope < floor) fastestMMPerMin = slope + floor;
  if (slope - slowestMMPerMin < floor) slowestMMPerMin = slope - floor;

  return {
    mmPerMin: slope,
    fitQuality,
    fastestMMPerMin,
    slowestMMPerMin,
    n,
  };
}
