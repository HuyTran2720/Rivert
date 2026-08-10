//
//  SiteState.swift
//  FloodApp
//
//  WHAT: Everything currently known about one monitored location. A
//        complete snapshot, not a stream.
//
//  WHY:  The server stores exactly one of these per site, overwritten on
//        every update. The app subscribes with a single listener and
//        renders whatever it says. The app never assembles a picture from
//        multiple sources and never decides which fields matter.
//
//  USED BY: DashboardController, FloodWidget, all dashboard views
//
//  STATUS: Complete. Pure data — no logic, no formatting, no computed
//          display properties. Formatting lives in Extensions/Formatters
//          because the widget needs it too and does not share controllers.
//
//  TARGET MEMBERSHIP: must be a member of BOTH the app target and the
//  widget extension target.
//

import Foundation

struct SiteState: Codable, Equatable, Sendable {

    let siteId: String

    // MARK: Measurement

    /// Water height above the channel bed, in millimetres.
    let levelMM: Double

    /// What the sensor actually measured, distance down to the water.
    /// Kept for transparency and for checking against a tape measure on site.
    let rawDistanceMM: Double

    // MARK: Rate

    /// Millimetres per hour. POSITIVE means water is rising.
    /// Nil means insufficient readings in that window — which is different
    /// from "not rising". Never default these to zero.
    let rate5m: Double?
    let rate15m: Double?
    let rate30m: Double?

    /// R² of the regression, 0 to 1. How linear the rise actually is.
    let rateConfidence: Double?

    // MARK: Thresholds

    /// Millimetres before water spreads onto the benches. Negative means
    /// it already has.
    let freeboardBenchMM: Double

    /// Millimetres before overspill at street level. Negative means it is
    /// already flooding.
    let freeboardBankMM: Double

    /// Nil when not rising.
    let timeToBenchMin: MinuteRange?
    let timeToBankMin: MinuteRange?

    // MARK: Judgement

    let riskState: RiskState
    let staleness: Staleness

    // MARK: Recession

    /// True once the level has turned and is falling.
    let isPeaking: Bool

    /// Only meaningful after the peak; nil otherwise.
    let timeUntilClearMin: MinuteRange?

    // MARK: History

    /// Short recent series for the trend sparkline.
    let recentLevels: [LevelPoint]

    // MARK: Provenance

    /// Device timestamp of the newest reading used.
    let latestReadingAt: Date

    /// When the server computed this snapshot.
    let computedAt: Date

    /// False while the site's calibration constants are still placeholders.
    /// The UI MUST surface this — an uncalibrated system produces
    /// structurally valid and numerically meaningless output.
    let calibrated: Bool
}
