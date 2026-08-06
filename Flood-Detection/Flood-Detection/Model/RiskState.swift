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
//  USED BY: ThresholdEvaluator, DashboardController, UserPlan,
//           DesignSystem (colour mapping, once decided)
//
//  STATUS: Implemented.
//

import Foundation

/// Simplified risk classification for display and alerting.
enum RiskState: String, Codable, CaseIterable {

    /// Below the "siaga" threshold. No action needed.
    case normal

    /// At or above "siaga". Something worth paying attention to.
    case watch

    /// At or above "awas", or drainage failure is imminent. User should
    /// be taking action.
    case act
}
