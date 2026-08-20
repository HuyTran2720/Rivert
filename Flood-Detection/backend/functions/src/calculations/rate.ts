import { LevelPoint, Rate } from "../types/models";
import { MS_PER_MIN, MIN_READINGS_FOR_RATE } from "../config";

/**
 * @param {number[]} xs Numbers.
 * @return {number} The mean.
 */
function mean(xs: number[]): number {
  let total = 0;
  for (const x of xs) total += x;
  return total / xs.length;
}

/**
 * Least-squares slope through the window. Null (never 0) when there is
 * not enough data.
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

  // x in minutes, y in mm, so the slope is already mm/min.
  const xs = win.map((p) => p.at.getTime() / MS_PER_MIN);
  const ys = win.map((p) => p.levelMM);
  const n = win.length;
  const xBar = mean(xs);
  const yBar = mean(ys);

  let sxy = 0;
  let sxx = 0;
  for (let i = 0; i < n; i++) {
    sxy += (xs[i] - xBar) * (ys[i] - yBar);
    sxx += (xs[i] - xBar) ** 2;
  }

  if (sxx === 0) return null;

  const slope = sxy / sxx;

  let ssRes = 0;
  let ssTot = 0;
  for (let i = 0; i < n; i++) {
    const fitted = yBar + slope * (xs[i] - xBar);
    ssRes += (ys[i] - fitted) ** 2;
    ssTot += (ys[i] - yBar) ** 2;
  }

  const r2 = ssTot === 0 ? 1 : 1 - ssRes / ssTot;
  const seMMPerMin = n > 2 ? Math.sqrt(ssRes / (n - 2) / sxx) : 0;

  return { mmPerMin: slope, r2, seMMPerMin };
}
