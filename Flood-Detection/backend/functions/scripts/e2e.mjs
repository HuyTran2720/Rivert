// End-to-end pipeline probe against the emulators.
//   1. seeds sites/<siteId> calibration
//   2. POSTs a rising series of readings to the ingest function
//   3. prints the state/<siteId> document the pipeline produced
//
// Run with the emulators already up (npm run serve):
//   FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 node scripts/e2e.mjs
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {fetchWeather} from "../lib/weather.js";

const PROJECT = process.env.GCLOUD_PROJECT ?? "bali-flood-8f6a4";
const REGION = "asia-southeast2";
const FN_HOST = process.env.FN_HOST ?? "127.0.0.1:5001";
const SECRET = process.env.DEVICE_SECRET ?? "dev-secret";
const SITE = process.env.SITE_ID ?? "legian-01";

process.env.FIRESTORE_EMULATOR_HOST ??= "127.0.0.1:8080";
initializeApp({projectId: PROJECT});
const db = getFirestore();

// Distances are measured DOWN from the sensor, so smaller = higher water.
const CAL = {
  d_bed: 3000,
  d_bench: 1800,
  d_bank: 1200,
  w_bottom: 2000,
  w_bench: 3500,
  w_top: 5000,
  sensor_offset_mm: 0,
  calibrated: true,
};

// Water climbing 200mm per reading, 10s apart — steep enough that
// rateOfRise has something to chew on inside RATE_WINDOW_MIN.
const START_MM = 2600;
const STEP_MM = 200;
const COUNT = Number(process.env.COUNT ?? 6);
const SPACING_MS = 10_000;

const url = `http://${FN_HOST}/${PROJECT}/${REGION}/ingest`;

/** @return {Promise<void>} */
async function main() {
  await db.doc(`sites/${SITE}`).set(CAL);
  console.log(`seeded sites/${SITE}`);

  // Wipe prior run so staleness/recompute gating starts clean.
  for (const c of ["readings", "state"]) {
    const snap = await db.collection(c).get();
    await Promise.all(snap.docs.map((d) => d.ref.delete()));
  }

  const now = Date.now();
  // One array POST, the way the device batches: a single request means a
  // single recompute that sees the whole window. Posting them one at a
  // time instead only recomputes on the first — the 30s gate swallows
  // the rest, and the state doc freezes on reading #1.
  const batch = [];
  for (let i = 0; i < COUNT; i++) {
    batch.push({
      deviceId: SITE,
      // Backdated so the series fits inside RATE_WINDOW_MIN, with the
      // last reading at ~now (otherwise staleness pins to "stale").
      timestamp: new Date(now - (COUNT - 1 - i) * SPACING_MS).toISOString(),
      rawDistanceMM: START_MM - i * STEP_MM,
    });
  }
  console.log(`POSTing ${batch.length} readings, ` +
    `${batch[0].rawDistanceMM}mm → ${batch[batch.length - 1].rawDistanceMM}mm`);

  const res = await fetch(url, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-device-secret": SECRET,
    },
    body: JSON.stringify(batch),
  });
  console.log(`→ ${res.status} ${await res.text()}`);

  // refreshWeather is a scheduled function, so the emulator never runs it
  // (no pubsub emulator). Stand in for it with the REAL fetchWeather so the
  // SSD carries a genuine 9-field Weather, and so the {merge:true} contract
  // between the two writers is actually exercised. Hand-stubbing this field
  // tests nothing except your own typing.
  if (process.env.SKIP_WEATHER !== "1") {
    const weather = await fetchWeather(new Date());
    if (weather) {
      await db.doc(`state/${SITE}`).set({weather}, {merge: true});
      console.log(`merged weather (${Object.keys(weather).length} fields)`);
    } else {
      console.warn("fetchWeather returned null — upstream down, no weather");
    }
  }

  const snap = await db.doc(`state/${SITE}`).get();
  if (!snap.exists) {
    console.error(`\nstate/${SITE} does not exist — nothing recomputed`);
    process.exit(1);
  }
  console.log(`\n--- state/${SITE} ---`);
  console.dir(snap.data(), {depth: null});
}

main().then(() => process.exit(0));
