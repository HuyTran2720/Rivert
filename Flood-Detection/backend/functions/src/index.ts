import { onRequest } from "firebase-functions/v2/https";
import { db } from "./db/firestore";

export { ingest } from "./ingest/handler";
export { refreshWeather, refreshWeatherHTTP } from "./weather/fetchWeather";
export { staleWatchDog, staleWatchdogHttp } from "./state/watchdog";
export { checkRiskAndNotify } from "./notify/push";

// ! TESTING PURPOSES
export const ping = onRequest(
  { region: "asia-southeast2" },
  async (req, res) => {
    if (req.get("x-device-secret") !== process.env.DEVICE_SECRET) {
      res.status(401).send("unauthorized");
      return;
    }
    const doc = await db.doc("sites/legian-01").get();
    res.json({ ok: true, site: doc.data() });
  },
);
