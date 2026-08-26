import { Reading, Calibration, SiteState, RiskState } from "../types/models";
import {
  RATE_WINDOW_MIN,
  CAUTION_RISE_MMPERMIN,
  MIN_FIT_QUALITY_FOR_PROJECTION,
} from "../config";
import { isPlausible } from "../calculations/validity";
import {
  toLevelPoints,
  levelMM,
  levelFraction,
} from "../calculations/level";
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
 * @param {RiskState | null} prevRiskState The riskState published last
 * time, or null on a cold start. Half of the hysteresis gate: raise and
 * clear use different thresholds, so the rung must know where it is.
 * @param {Date | null} prevRiskStateSince When riskState last changed,
 * or null on a cold start. The other half — supplies the dwell time.
 * @return {SiteState | null} The state, or null if nothing is usable.
 */
export function computeSiteState(
  siteId: string,
  readings: Reading[],
  cal: Calibration,
  now: Date,
  prevRateMMPerMin: number | null = null,
  prevRiskState: RiskState | null = null,
  prevRiskStateSince: Date | null = null,
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
  // Water actually over the street is unaffected — that rung reads
  // freeboard directly and does not depend on any projection.
  const sustained =
    rate !== null &&
    rate.mmPerMin > 0 &&
    prevRateMMPerMin !== null &&
    prevRateMMPerMin > 0;

  // "Rising" for the level rung, deliberately strict. Three conditions,
  // each killing a different false positive:
  //   slowestMMPerMin  — the PESSIMISTIC (p10) edge of the band must
  //                      clear the bar, so a fit straddling zero never
  //                      counts as a rise.
  //   CAUTION_RISE_...  — magnitude, not sign. Theil-Sen on a quantised
  //                      sensor yields small non-zero slopes on flat
  //                      water; this is the noise floor, and it is what
  //                      keeps a slow spring tide out of the badge.
  //   fitQuality        — a rate fitted through noise is not a trend.
  const rising =
    rate !== null &&
    rate.slowestMMPerMin > CAUTION_RISE_MMPERMIN &&
    rate.fitQuality >= MIN_FIT_QUALITY_FOR_PROJECTION;

  const fraction = levelFraction(fbBank, cal);

  const heldForSec = prevRiskStateSince ?
    (now.getTime() - prevRiskStateSince.getTime()) / 1000 :
    Number.POSITIVE_INFINITY; // cold start: nothing to debounce against

  const projected = timeToBank(fbBench, fbBank, rate, cal);
  const toBank = sustained ? projected : null;

  const state = staleness(latest.timestamp, now);

  const riskState = classifyRisk({
    staleness: state,
    timeToBankMin: toBank,
    freeboardBankMM: fbBank,
    haveRate: rate !== null,
    levelFraction: fraction,
    rising,
    prevRiskState,
    heldForSec,
  });

  const changed = prevRiskState !== null && prevRiskState !== riskState;

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
    riskState,
    /** When riskState last CHANGED. Feeds the dwell gate; carried
     * forward untouched while the state holds. */
    riskStateSince: changed ? now : (prevRiskStateSince ?? now),
    staleness: state,
    latestReadingAt: latest.timestamp,
    computedAt: now,
    calibrated: cal.calibrated,
  };
}
