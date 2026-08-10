//
//  RiskState.swift
//  Flood-Detection
//
//  WHAT: The three-level risk classification shown to the user: normal,
//        watch, or act.
//
//  WHY:  Raw millimetre numbers don't mean anything to someone deciding
//        whether to move their belongings upstairs. This is the
//        simplified output ThresholdEvaluator produces from level +
//        thresholds, and everything UI-facing (colour, copy, alerts)
//        keys off it.
//
//  USED BY: SiteState, DashboardController
//
//  STATUS: Implemented.
//

import Foundation

/// Simplified risk classification for display and alerting.
enum RiskState: String, Codable, CaseIterable {

    /// Below the "siaga" threshold. No action needed.
    case normal

    /// At or above "siaga". Something worth paying attention to.
    /// freeboardBenchMM <= 0, OR timeToBankMin.lowerBound < 120
    case watch

    /// At or above "awas", or drainage failure is imminent. User should be taking action.
    /// timeToBankMin.lowerBound < 30
    case act
    
    /// The water is over the bank now
    /// freeboardBankMM <= 0
    case flooding
    
    /// Stale or low confidence
    case unknown
}
