//
//  Staleness.swift
//  FloodApp
//
//  WHAT: How current the information is, based on the age of the newest
//        sensor reading.
//
//  WHY:  Deliberately SEPARATE from RiskState. A dead sensor and a calm
//        river produce identical silence. If this were folded into
//        RiskState, a device that lost power during a storm would leave
//        "normal" on screen while the street floods.
//        The UI must make "the water is fine" and "we have not heard
//        anything for twenty minutes" look different.
//
//  USED BY: SiteState, DashboardController, FloodWidget
//
//  STATUS: Complete.
//

import Foundation

enum Staleness: String, Codable, Sendable {
    case fresh      // newest reading under 2 minutes old
    case stale      // 2 to 15 minutes
    case noData     // over 15 minutes
}
