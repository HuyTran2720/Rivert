//
//  RiskState.swift
//  Flood-Detection
//
//  WHAT: The risk classification shown to the user: normal, caution,
//        danger, or unknown.
//
//  WHY:  Raw millimetre numbers don't mean anything to someone deciding
//        whether to move their belongings upstairs. This is the
//        simplified output the backend produces from level + rate of
//        rise, and everything UI-facing (colour, copy, alerts) keys off
//        it.
//
//  MIRRORS: RiskState in backend/functions/src/calc.ts. The raw values
//        below are decoded straight from the state document, so both
//        sides must use the same spellings.
//
//  USED BY: SiteState, DashboardController
//
//  STATUS: Implemented.
//

import Foundation

/// Simplified risk classification for display and alerting.
enum RiskState: String, Codable, CaseIterable {

    /// Nothing to do. Water is low, or not rising fast enough to matter.
    case normal

    /// Worth paying attention to. Either the water has already spread
    /// onto the benches, or it is projected to overspill before long.
    case caution

    /// Take action now. Either the water is over the bank already, or
    /// overspill is projected within minutes.
    case danger

    /// The sensor has gone quiet, or we could not fit a rate of rise.
    /// Never shown as "safe" — silence and calm look identical.
    case unknown
}
