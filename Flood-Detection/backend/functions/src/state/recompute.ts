import { Reading, Calibration, SiteState } from "../types/models";
import { RATE_WINDOW_MIN } from "../config";
import { isPlausible } from "../calculations/validity";
import { toLevelPoints, levelMM } from "../calculations/level";
import { rateOfRise } from "../calculations/rate";
import { freeboardBenchMM, freeboardBankMM } from "../calculations/freeboard";
import { timeToBank } from "../calculations/projection";
import { leadTime } from "../calculations/leadTime";
import { staleness } from "../calculations/staleness";
import { classifyRisk } from "../calculations/riskState";

/**
 * The only function ingest needs to call. Pure — no Firebase imports —
 * so it's testable with plain arrays and dates.
 *
 * @param {string} siteId Which site.
 * @param {Reading[]} readings The recent raw readings.
 * @param {Calibration} cal Site calibration.
 * @param {Date} now Current time, passed in so tests can control it.
 * @param {number | null} prevRateMMPerMin The rate the previous
 * recompute published, or null if there wasn't one. Used only to
 * confirm a rise has repeated before any countdown goes out.
 * @return {SiteState | null} The state, or null if nothing is usable.
 */
export function computeSiteState(
  siteId: string,
  readings: Reading[],
  cal: Calibration,
  now: Date,
  prevRateMMPerMin: number | null = null,
): SiteState | null {
  const good = readings
    .filter((r) => isPlausible(r, cal))
    .sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime());

  if (good.length === 0) return null;

  const latest = good[good.length - 1];
  const points = toLevelPoints(good, cal);

  const rate = rateOfRise(points, RATE_WINDOW_MIN, now);

  const fbBench = freeboardBenchMM(latest.rawDistanceMM, cal);
  const fbBank = freeboardBankMM(latest.rawDistanceMM, cal);

  // A countdown only goes out once the rise has shown up twice running.
  // Costs one recompute cycle (~30s) of lead time on a projected
  // danger; buys immunity from the danger/normal flapping that would
  // otherwise fire a push on every oscillation and get the app muted.
  // Water actually over the bank is unaffected — bankConfirmed below
  // does not depend on any projection.
  const sustained =
    rate !== null &&
    rate.mmPerMin > 0 &&
    prevRateMMPerMin !== null &&
    prevRateMMPerMin > 0;

  const projected = timeToBank(fbBench, fbBank, rate, cal);
  const toBank = sustained ? projected : null;

  const prev = good.length > 1 ? good[good.length - 2] : null;
  const bankConfirmed =
    fbBank <= 0 &&
    prev !== null &&
    freeboardBankMM(prev.rawDistanceMM, cal) <= 0;

  const state = staleness(latest.timestamp, now);

  return {
    siteId,
    levelMM: levelMM(latest.rawDistanceMM, cal),
    rateMMPerMin: rate ? rate.mmPerMin : null,
    freeboardMM: fbBank,
    timeToBankMin: toBank,
    leadTime: leadTime({
      freeboardBankMM: fbBank,
      timeToBankMin: toBank,
      rate,
      sustained,
    }),
    riskState: classifyRisk({
      staleness: state,
      freeboardBenchMM: fbBench,
      timeToBankMin: toBank,
      bankConfirmed,
      haveRate: rate !== null,
    }),
    staleness: state,
    latestReadingAt: latest.timestamp,
    computedAt: now,
    calibrated: cal.calibrated,
  };
}
