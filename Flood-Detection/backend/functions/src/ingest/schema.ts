export interface WireReading {
  deviceId: string;
  timestamp: string;
  rawDistanceMM: number;
}

/**
 * @param {unknown} r Anything that arrived in the request body.
 * @return {boolean} True if it has the shape of a WireReading.
 */
export function isValidReading(r: unknown): r is WireReading {
  if (typeof r !== "object" || r === null) return false;
  const x = r as Record<string, unknown>;
  return (
    typeof x.deviceId === "string" && x.deviceId.length > 0 &&
    typeof x.timestamp === "string" &&
    !isNaN(Date.parse(x.timestamp)) &&
    typeof x.rawDistanceMM === "number"
  );
}
