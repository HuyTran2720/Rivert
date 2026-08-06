//
//  Reading.swift
//  Flood-Detection
//
//  WHAT: A single water level measurement, plus the raw sensor value it was
//        derived from and how confident we are in it.
//
//  WHY:  Every screen, calculation, and alert in this app is ultimately
//        about readings: how high is the water, how fast is it changing,
//        and can we trust the number. This is the one shape all of that
//        data flows through, regardless of whether it came from a real
//        sensor, an archive, or the mock replay.
//
//  USED BY: ReadingSource and its implementations, RateCalculator,
//           ThresholdEvaluator, DashboardController
//
//  STATUS: Implemented. Plain data, no persistence, no networking.
//

import Foundation

/// A single water level measurement from any source (sensor, archive,
/// or replay file). Immutable once created.
struct Reading: Identifiable, Codable, Equatable {
    let id: UUID

    /// When the measurement was taken at the sensor, not when it was
    /// received by the app.
    let timestamp: Date

    /// Water level above the site datum, in millimetres. Derived from
    /// rawDistanceMM and the site's sensorHeightMM.
    let levelMM: Double

    /// The unprocessed distance the sensor reported (e.g. ultrasonic
    /// distance-to-surface), in millimetres, before converting to a
    /// level relative to the datum. Kept around for debugging bad
    /// readings without needing to re-derive it.
    let rawDistanceMM: Double

    /// Which kind of source produced this reading. Useful for debugging
    /// and for labelling data in previews/demos as not-real.
    let source: ReadingOrigin

    // TODO: confirm whether confidence comes from the sensor itself or is
    // computed here from reading variance. Currently just carried through
    // from whatever source produced the reading.
    let confidence: Double
}

/// Where a Reading came from. Not the same thing as ReadingSource (the
/// protocol) — this is a lightweight tag carried on the data itself.
enum ReadingOrigin: String, Codable {
    case mock
    case sensor
    case archive
}
