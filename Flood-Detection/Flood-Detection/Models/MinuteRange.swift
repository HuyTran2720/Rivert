//
//  MinuteRange.swift
//  FloodApp
//
//  WHAT: A range of minutes, e.g. 1.4 to 2.6.
//
//  WHY:  Every projected value is a range, never a point estimate.
//        "1.4 to 2.6 minutes" survives contact with reality; "2 minutes"
//        does not. Swift's ClosedRange is not cleanly Codable across the
//        JSON shape the server sends, so this wraps it.
//
//  USED BY: SiteState
//
//  STATUS: Complete.
//

import Foundation

struct MinuteRange: Codable, Equatable, Sendable {
    // Double, not Int: at demo scale the server rounds to one
    // decimal place, so whole minutes would fail to decode.
    let lower: Double
    let upper: Double
}
