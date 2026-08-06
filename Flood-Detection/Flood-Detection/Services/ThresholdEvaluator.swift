//
//  ThresholdEvaluator.swift
//  Flood-Detection
//
//  WHAT: Turns a water level (and optionally a rate of rise) into a
//        RiskState, and projects how long until a rising level crosses a
//        given threshold.
//
//  WHY:  RateCalculator tells you the raw numbers; this is where those
//        numbers become the normal/watch/act classification the UI and
//        alerts key off, and the "you have N minutes" projection that's
//        the actual point of the app.
//
//  USED BY: DashboardController, UserPlan generation (once built)
//
//  STATUS: Implemented for the level-based classification. Rate-based
//          early warning (flagging .watch before siagaMM is crossed, if
//          rate of rise is high enough) is deliberately not implemented —
//          see TODO. Needs unit tests once a test target exists.
//

import Foundation

enum ThresholdEvaluator {

    /// Classifies current risk from level alone. `rate` is accepted for
    /// future use but not yet factored in.
    static func riskState(level: Double, rate: Double?, threshold: Threshold) -> RiskState {
        if level >= threshold.awasMM {
            return .act
        }
        if level >= threshold.siagaMM {
            return .watch
        }
        // TODO: decide whether a fast rate of rise, on its own, before
        // level crosses siagaMM, should also produce .watch. Product
        // decision not made yet — rate is currently unused here.
        return .normal
    }

    /// Linear projection of how long until `level` reaches `threshold`,
    /// given a constant `rate` (mm/hour). Returns nil if not rising
    /// (rate <= 0) or already at/past the threshold.
    static func timeToThreshold(level: Double, rate: Double, threshold: Double) -> TimeInterval? {
        guard rate > 0, threshold > level else { return nil }
        let hoursRemaining = (threshold - level) / rate
        return hoursRemaining * 3600
    }
}
