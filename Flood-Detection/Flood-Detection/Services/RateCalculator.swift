//
//  RateCalculator.swift
//  Flood-Detection
//
//  WHAT: Computes how fast the water level is rising, in mm per hour, from
//        a series of readings, plus a median-reading helper for filtering
//        out noisy outliers.
//
//  WHY:  Water level alone tells you where the river is now. Rate of rise
//        tells you where it's going, and — combined with ThresholdEvaluator
//        — how long before it reaches a level that matters. This is the
//        core calculation the rest of the app's risk logic is built on.
//
//  USED BY: ThresholdEvaluator, DashboardController
//
//  STATUS: Implemented. Pure functions, no dependencies. Needs unit tests
//          once a test target exists (none does yet in this project).
//

import Foundation

enum RateCalculator {

    /// Rate of change of water level over the given trailing window, in
    /// millimetres per hour. Uses the earliest and latest reading inside
    /// the window; returns nil if fewer than two readings fall in it.
    static func rate(from readings: [Reading], window: TimeInterval) -> Double? {
        guard let newestTimestamp = readings.map(\.timestamp).max() else {
            return nil
        }
        let windowStart = newestTimestamp.addingTimeInterval(-window)
        let windowed = readings
            .filter { $0.timestamp >= windowStart }
            .sorted { $0.timestamp < $1.timestamp }

        guard let first = windowed.first,
              let last = windowed.last,
              first.timestamp != last.timestamp else {
            return nil
        }

        let levelDeltaMM = last.levelMM - first.levelMM
        let elapsedHours = last.timestamp.timeIntervalSince(first.timestamp) / 3600
        guard elapsedHours > 0 else { return nil }

        return levelDeltaMM / elapsedHours
    }

    /// The reading with the median level in the given set, useful for
    /// discarding a single noisy/spiky sensor reading before computing a
    /// rate. Returns nil for an empty array.
    static func median(of readings: [Reading]) -> Reading? {
        guard !readings.isEmpty else { return nil }
        let sortedByLevel = readings.sorted { $0.levelMM < $1.levelMM }
        return sortedByLevel[sortedByLevel.count / 2]
    }
}
