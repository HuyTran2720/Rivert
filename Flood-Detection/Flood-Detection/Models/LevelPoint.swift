//
//  LevelPoint.swift
//  FloodApp
//
//  WHAT: One point in the recent level history, for the trend sparkline.
//
//  WHY:  The sparkline needs a series, but the app must not query raw
//        readings or interpret them. The server trims and includes a short
//        history inside SiteState so the app receives display-ready points.
//
//  USED BY: SiteState, trend sparkline component
//
//  STATUS: Complete. NOTE: this is an addition to the original contract —
//          confirm the server includes recentLevels before relying on it.
//

import Foundation

struct LevelPoint: Codable, Equatable, Sendable {
    let at: Date
    let levelMM: Double
}
