export const OPEN_METEO_URL =
  "https://api.open-meteo.com/v1/forecast" +
  "?latitude=-8.7038&longitude=115.1728" +
  "&hourly=precipitation_probability&forecast_days=2&timezone=UTC";

interface OpenMeteoResponse {
  hourly?: {
    time?: unknown[];
    precipitation_probability?: unknown[];
  };
}

/** One hourly rain-probability point from Open-Meteo. */
export interface ProbPoint {
  at: Date;
  probabilityPct: number;
}

/**
 * @param {unknown} v Any value from an external payload.
 * @return {number} The number, or 0 if it was missing or not finite.
 */
function num(v: unknown): number {
  return typeof v === "number" && Number.isFinite(v) ? v : 0;
}

/**
 * @param {unknown} v Any value from an external payload.
 * @return {string} The string, or "" if it was missing.
 */
function str(v: unknown): string {
  return typeof v === "string" ? v : "";
}

/**
 * Open-Meteo returns "2026-08-19T00:00" with no zone marker, which JS
 * parses as LOCAL time. Without the appended Z every point shifts.
 *
 * @param {unknown} raw The decoded Open-Meteo response.
 * @return {ProbPoint[]} Points, oldest first. Empty if unparseable.
 */
export function parseOpenMeteo(raw: unknown): ProbPoint[] {
  const hourly = (raw as OpenMeteoResponse)?.hourly;
  const times = hourly?.time;
  const probs = hourly?.precipitation_probability;
  if (!Array.isArray(times) || !Array.isArray(probs)) return [];

  const out: ProbPoint[] = [];
  for (let i = 0; i < times.length; i++) {
    const t = str(times[i]);
    if (t === "") continue;
    const iso = t.endsWith("Z") ? t : `${t}${t.length === 16 ? ":00" : ""}Z`;
    const at = new Date(iso);
    if (Number.isNaN(at.getTime())) continue;
    out.push({ at, probabilityPct: num(probs[i]) });
  }
  return out.sort((a, b) => a.at.getTime() - b.at.getTime());
}
