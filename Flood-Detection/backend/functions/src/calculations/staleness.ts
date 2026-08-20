import { Staleness } from "../types/models";
import { MS_PER_MIN, STALE_AFTER_MIN, NO_DATA_AFTER_MIN } from "../config";

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
