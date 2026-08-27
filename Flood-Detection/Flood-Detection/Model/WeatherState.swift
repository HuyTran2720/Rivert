//
//  WeatherState.swift
//  Flood-Detection
//
//  WHAT: The `weather` map merged onto state/{siteId} by the
//        refreshWeather Cloud Function.
//
//  MIRRORS: Weather / ForecastSlot in
//        backend/functions/src/weather/fetchWeather.ts.
//        Field names below are the wire format — if one side changes,
//        change the other.
//

import Foundation
import FirebaseFirestore

/// One 3-hour BMKG forecast slot.
struct ForecastSlot: Codable, Equatable {
    let at: Timestamp
    let tempC: Double
    /// Total precipitation across the whole 3h slot, mm.
    let precipMM: Double
    /// BMKG's English description. Drives the icon — see WeatherIcon.
    let description: String
    /// BMKG's own icon URL. Unused: we render local assets instead so
    /// the strip works offline and matches the illustration style.
    let iconURL: String?

    var date: Date { at.dateValue() }
}

/// Written by refreshWeather; absent until it has run at least once.
struct WeatherState: Codable, Equatable {
    /// Index 0 IS the current slot — the backend deliberately keeps no
    /// separate copy of "now" that could drift out of sync.
    let forecast: [ForecastSlot]
    let next6hTotalMM: Double?
    let rainStartsAt: Timestamp?
    let rainDurationHours: Double?
    let fetchedAt: Timestamp?
}
