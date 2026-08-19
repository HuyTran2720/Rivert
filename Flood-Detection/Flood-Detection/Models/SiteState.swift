//
//  SiteState.swift
//  Flood-Detection
//
//  WHAT: The single document the app reads. Everything on screen comes
//        from one snapshot of this type.
//
//  WHY:  The app subscribes to one document and renders whatever it
//        says. It never assembles a picture from pieces, so the server
//        has to hand it a complete, self-consistent state every time.
//
//  MIRRORS: SiteState in backend/functions/src/calc.ts, plus the
//        `weather` field which is merged onto the same document by the
//        refreshWeather scheduled function. If you change one, change
//        the other — the field names below are the wire format.
//
//  USED BY: DashboardController, MainInfoView
//
//  STATUS: Implemented.
//

import Foundation

struct SiteState: Codable, Equatable, Sendable {

    let siteId: String

    /// Water height above the channel bed, mm.
    let levelMM: Double

    /// Positive means rising. Nil means we could not fit a rate at all,
    /// which is NOT the same as "not rising" — show them differently.
    let rateMMPerMin: Double?

    /// How far the water is from spilling over at street level, mm.
    /// Negative means it already has.
    let freeboardMM: Double

    /// Minutes until overspill. Nil when the water is not rising, is
    /// already over, or is further out than the server will project.
    let timeToBankMin: MinuteRange?

    let riskState: RiskState

    /// Age of the newest sensor reading. Separate from riskState on
    /// purpose — see Staleness.swift.
    let staleness: Staleness

    let latestReadingAt: Date

    let computedAt: Date

    /// False while the tape-measured site geometry is still a
    /// placeholder. Every number above is fiction until this is true.
    let calibrated: Bool

    /// Nil until refreshWeather has run at least once, or if the
    /// forecast APIs were unreachable on every attempt.
    let weather: Weather?
}
