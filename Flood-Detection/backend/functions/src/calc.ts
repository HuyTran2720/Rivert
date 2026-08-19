// Pure calculations: raw sensor distances in, SiteState out.
// Imports nothing from Firebase so it can be tested with plain numbers.
// Tuning constants below are DEMO values, not field values.

export interface Reading {
  deviceId: string;
  timestamp: Date;
  rawDistanceMM: number;
}

/** Reading as it arrives over HTTP. Mirrors the interface in index.ts. */
export interface WireReading {
  deviceId: string;
  timestamp: string;
  rawDistanceMM: number;
}

/**
 * @param {WireReading} w A reading as received over HTTP.
 * @return {Reading} The same reading with a real Date.
 */
export function toReading(w: WireReading): Reading {
  return {
    deviceId: w.deviceId,
    timestamp: new Date(w.timestamp),
    rawDistanceMM: w.rawDistanceMM,
  };
}

/** Tape-measured site geometry. All distances measured DOWN from the
 * sensor, so dBank < dBench < dBed. */
export interface Calibration {
  d_bed: number;
  d_bench: number;
  d_bank: number;
  w_bottom: number;
  w_bench: number;
  w_top: number;
  calibrated: boolean;
}

export interface MinuteRange {
  lower: number;
  upper: number;
}

export type RiskState =
  | "normal"
  | "caution"
  | "danger"
  | "unknown";

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

/** The single document the app reads. Weather is merged in by ingest. */
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

// Demo values. Field values in brackets.
export const RATE_WINDOW_MIN = 1; // [15]
const MIN_READINGS_FOR_RATE = 3;
const MAX_PROJECTION_MIN = 10; // [240]
const DANGER_WITHIN_MIN = 1; // [30]
const CAUTION_WITHIN_MIN = 4; // [120]
const STALE_AFTER_MIN = 0.5; // [2]
const NO_DATA_AFTER_MIN = 2; // [15]

const MS_PER_MIN = 60 * 1000;

/**
 * @param {Reading} r The reading to check.
 * @param {Calibration} cal Site calibration.
 * @return {boolean} True if the reading is geometrically possible.
 */
export function isPlausible(r: Reading, cal: Calibration): boolean {
  if (r.rawDistanceMM > cal.d_bed + 100) return false;
  if (r.rawDistanceMM < cal.d_bank - 500) return false;
  return true;
}

/**
 * @param {number} rawDistanceMM Sensor reading.
 * @param {Calibration} cal Site calibration.
 * @return {number} Water height above the channel bed, mm.
 */
export function levelMM(rawDistanceMM: number, cal: Calibration): number {
  return cal.d_bed - rawDistanceMM;
}

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
 * @param {number} rawDistanceMM Sensor reading.
 * @param {Calibration} cal Site calibration.
 * @return {number} Freeboard to street level, mm. Negative = over bank.
 */
export function freeboardBankMM(
  rawDistanceMM: number,
  cal: Calibration,
): number {
  return rawDistanceMM - cal.d_bank;
}

/**
 * @param {Reading[]} readings Raw readings, any order.
 * @param {Calibration} cal Site calibration.
 * @return {LevelPoint[]} Usable points, oldest first.
 */
export function toLevelPoints(
  readings: Reading[],
  cal: Calibration,
): LevelPoint[] {
  return readings
    .filter((r) => isPlausible(r, cal))
    .map((r) => ({at: r.timestamp, levelMM: levelMM(r.rawDistanceMM, cal)}))
    .sort((a, b) => a.at.getTime() - b.at.getTime());
}

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

  return {mmPerMin: slope, r2, seMMPerMin};
}

/**
 * @param {number} x The value to round.
 * @return {number} x rounded to one decimal place.
 */
function round1(x: number): number {
  return Math.round(x * 10) / 10;
}

/**
 * Climb time. Below the bench the channel holds a constant width
 * (w_bottom). Above the bench the walls slope outward on a straight
 * grade — width increases linearly from (w_bottom + w_bench) at the
 * bench up to w_top at the bank. The trapezoidal average of those two
 * endpoints is the exact integral of a linear width function.
 *
 * @param {number} narrowMM Distance to climb inside the channel.
 * @param {number} wideMM Distance to climb above the benches.
 * @param {number} rateMMPerMin Rise rate measured in the channel.
 * @param {Calibration} cal Site calibration.
 * @return {number} Minutes, or Infinity if not rising.
 */
function travelMinutes(
  narrowMM: number,
  wideMM: number,
  rateMMPerMin: number,
  cal: Calibration,
): number {
  if (rateMMPerMin <= 0) return Infinity;

  const narrowMin = Math.max(0, narrowMM) / rateMMPerMin;

  // Q is constant; the measured rate reflects width w_bottom.
  const q = cal.w_bottom * rateMMPerMin;
  const widthAtBench = cal.w_bottom + cal.w_bench;
  const avgWideWidth = (widthAtBench + cal.w_top) / 2;
  const wideMin = q > 0 ?
    (Math.max(0, wideMM) * avgWideWidth) / q :
    Infinity;

  return narrowMin + wideMin;
}

/**
 * Project with the fastest and slowest believable rate (95% band).
 *
 * @param {number} narrowMM Distance to climb inside the channel.
 * @param {number} wideMM Distance to climb above the benches.
 * @param {Rate} rate The fitted rate of rise.
 * @param {Calibration} cal Site calibration.
 * @return {MinuteRange | null} The range, or null if not projectable.
 */
function projectRange(
  narrowMM: number,
  wideMM: number,
  rate: Rate,
  cal: Calibration,
): MinuteRange | null {
  if (rate.mmPerMin <= 0) return null;

  const band = 1.96 * rate.seMMPerMin;
  const fastest = rate.mmPerMin + band;
  const slowest = rate.mmPerMin - band;

  const lower = travelMinutes(narrowMM, wideMM, fastest, cal);
  const upper = travelMinutes(narrowMM, wideMM, slowest, cal);

  if (!Number.isFinite(lower) || lower > MAX_PROJECTION_MIN) return null;

  const lowerMin = Math.max(0, round1(lower));
  const upperMin = Math.min(
    MAX_PROJECTION_MIN,
    Number.isFinite(upper) ? round1(upper) : MAX_PROJECTION_MIN,
  );

  return {lower: lowerMin, upper: Math.max(lowerMin, upperMin)};
}

/**
 * @param {number} fbBenchMM Freeboard to the benches.
 * @param {number} fbBankMM Freeboard to the bank.
 * @param {Rate | null} rate Fitted rate of rise.
 * @param {Calibration} cal Site calibration.
 * @return {MinuteRange | null} Minutes until overspill, or null.
 */
export function timeToBank(
  fbBenchMM: number,
  fbBankMM: number,
  rate: Rate | null,
  cal: Calibration,
): MinuteRange | null {
  if (!rate) return null;
  if (fbBankMM <= 0) return null;

  const narrowMM = Math.max(0, fbBenchMM);
  const wideMM = fbBankMM - narrowMM;

  return projectRange(narrowMM, wideMM, rate, cal);
}

/**
 * @param {Date} latestReadingAt Timestamp of the newest reading.
 * @param {Date} now Current time.
 * @return {Staleness} fresh, stale, or noData.
 */
export function staleness(latestReadingAt: Date, now: Date): Staleness {
  const ageMin = (now.getTime() - latestReadingAt.getTime()) / MS_PER_MIN;
  if (ageMin > NO_DATA_AFTER_MIN) return "noData";
  if (ageMin > STALE_AFTER_MIN) return "stale";
  return "fresh";
}

export interface RiskInput {
  staleness: Staleness;
  freeboardBenchMM: number;
  timeToBankMin: MinuteRange | null;
  bankConfirmed: boolean;
  haveRate: boolean;
}

/**
 * The ladder, top down. Deliberately cannot see rainfall or tide.
 *
 * @param {RiskInput} input The measured facts.
 * @return {RiskState} The classification.
 */
export function classifyRisk(input: RiskInput): RiskState {
  if (input.staleness === "noData") return "unknown";
  if (!input.haveRate) return "unknown";

  // Water is over the bank now, confirmed twice.
  if (input.bankConfirmed) return "danger";

  const soonest = input.timeToBankMin?.lower ?? null;

  if (soonest !== null && soonest < DANGER_WITHIN_MIN) return "danger";

  if (input.freeboardBenchMM <= 0) return "caution";
  if (soonest !== null && soonest < CAUTION_WITHIN_MIN) return "caution";

  return "normal";
}

/**
 * The only function ingest needs to call.
 *
 * @param {string} siteId Which site.
 * @param {Reading[]} readings The recent raw readings.
 * @param {Calibration} cal Site calibration.
 * @param {Date} now Current time, passed in so tests can control it.
 * @return {SiteState | null} The state, or null if nothing is usable.
 */
export function computeSiteState(
  siteId: string,
  readings: Reading[],
  cal: Calibration,
  now: Date,
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

  const toBank = timeToBank(fbBench, fbBank, rate, cal);

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
