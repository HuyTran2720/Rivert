//
//  Weather.swift
//  Flood-Detection
//
//  WHAT: Forecast context shown beside the water reading. Rain rate,
//        when rain starts, how long it lasts, and how likely it is.
//
//  WHY:  Context only. Weather NEVER influences RiskState — that stays
//        derived purely from what the sensor measured. A forecast that
//        does not materialise must not be able to raise an alarm, and a
//        clear sky must not be able to lower one.
//
//  MIRRORS: Weather in backend/functions/src/weather.ts.
//        BMKG supplies everything except the two probabilities, which
//        come from Open-Meteo and are nil if that call failed.
//
//  USED BY: SiteState
//
//  STATUS: Implemented.
//

import Foundation

struct Weather: Codable, Equatable, Sendable {

    /// English description of the current 3-hour slot, e.g. "Partly Cloudy".
    let nowDesc: String

    /// BMKG's own icon for that description. change accordingly
    let nowIconURL: String

    let nowTempC: Double

    /// Millimetres per hour, derived from BMKG's 3-hourly total.
    let precipRateMMPerHour: Double

    /// Chance of rain this hour. Nil if Open-Meteo was unreachable.
    let precipProbabilityNowPct: Double?

    /// Peak chance of rain across the next 6 hours.
    let precipProbabilityNext6hPct: Double?

    /// Total rain expected over the next 6 hours, mm.
    let next6hTotalMM: Double

    /// When rain next begins. Searched across the whole forecast, so
    /// this can be a long way out. Nil when the forecast is dry.
    let rainStartsAt: Date?

    /// Resolution is 3 hours, not minutes — BMKG publishes 3-hour slots.
    let rainDurationHours: Double?

    /// When the server last pulled the forecast.
    let fetchedAt: Date
}

extension Weather {

    /// Computed here rather than stored on the server, deliberately.
    ///
    /// A stored staleness would be stamped once at fetch time and then
    /// keep claiming "fresh" forever if the scheduled refresh died.
    /// Deriving it from `fetchedAt` means silence looks like silence.
    ///
    /// Thresholds are generous because BMKG only re-runs its model
    /// every 6 hours or so.
    func staleness(asOf now: Date = Date()) -> Staleness {
        let ageMinutes = now.timeIntervalSince(fetchedAt) / 60
        if ageMinutes > 720 { return .noData }   // 12 hours
        if ageMinutes > 180 { return .stale }    // 3 hours
        return .fresh
    }

    /// True when rain is expected within the next six hours.
    var isRainExpectedSoon: Bool {
        next6hTotalMM > 0
    }
}
