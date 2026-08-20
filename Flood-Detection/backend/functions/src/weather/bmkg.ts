export const BMKG_URL =
  "https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=51.03.01.1004";

interface BmkgEntry {
  datetime?: unknown;
  t?: unknown;
  tp?: unknown;
  tcc?: unknown;
  hu?: unknown;
  weather_desc_en?: unknown;
  image?: unknown;
}

interface BmkgResponse {
  data?: { cuaca?: BmkgEntry[][] }[];
}

/** One parsed BMKG 3-hour forecast slot. */
export interface WeatherSlot {
  at: Date;
  tempC: number;
  /** Total precipitation across the whole 3h slot, mm. */
  precipMM: number;
  cloudPct: number;
  humidityPct: number;
  description: string;
  iconURL: string;
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
 * Flatten BMKG's nested day groups into one sorted list.
 *
 * @param {unknown} raw The decoded BMKG response.
 * @return {WeatherSlot[]} Slots, oldest first. Empty if unparseable.
 */
export function parseBMKG(raw: unknown): WeatherSlot[] {
  const groups = (raw as BmkgResponse)?.data?.[0]?.cuaca;
  if (!Array.isArray(groups)) return [];

  const out: WeatherSlot[] = [];
  for (const group of groups) {
    if (!Array.isArray(group)) continue;
    for (const e of group) {
      const at = new Date(str(e?.datetime));
      if (Number.isNaN(at.getTime())) continue;
      out.push({
        at,
        tempC: num(e.t),
        precipMM: num(e.tp),
        cloudPct: num(e.tcc),
        humidityPct: num(e.hu),
        description: str(e.weather_desc_en),
        iconURL: str(e.image),
      });
    }
  }
  return out.sort((a, b) => a.at.getTime() - b.at.getTime());
}
