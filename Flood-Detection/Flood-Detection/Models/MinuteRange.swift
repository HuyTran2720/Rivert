//
//  MinuteRange.swift
//  FloodApp
//
//  WHAT: A range of minutes, e.g. 28 to 52.
//
//  WHY:  Every projected value is a range, never a point estimate.
//        "28 to 52 minutes" survives contact with reality; "40 minutes"
//        does not. Swift's ClosedRange is not cleanly Codable across the
//        JSON shape the server sends, so this wraps it.
//
//  USED BY: SiteState
//
//  STATUS: Complete.
//

import Foundation

struct MinuteRange: Codable, Equatable, Sendable {
    let lower: Int
    let upper: Int
}
