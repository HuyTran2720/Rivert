//
//  Site.swift
//  Flood-Detection
//
//  WHAT: A monitored location — a river gauge point — with the physical
//        setup needed to turn raw sensor distances into water levels, and
//        the thresholds that define risk at that specific site.
//
//  WHY:  Thresholds and sensor geometry are not universal constants; they
//        depend on the local riverbed, drainage, and how the sensor is
//        mounted. Bundling that per-location config into one type means
//        the rest of the app can ask "what does normal/watch/act mean
//        here" without hardcoding numbers.
//
//  USED BY: ThresholdEvaluator, DashboardController, OnboardingController
//
//  STATUS: Implemented as plain data. Where Site data itself comes from
//          (bundled config, remote fetch, user setup during onboarding)
//          is not yet decided.
//

import Foundation

/// A single monitored river location.
struct Site: Identifiable, Codable, Equatable {
    let id: UUID

    /// Human-readable name shown in the UI, e.g. "Ciliwung — Kampung Melayu".
    let name: String

    /// Height of the sensor above the site's datum, in millimetres. Used
    /// to convert a raw sensor distance reading into levelMM.
    let sensorHeightMM: Double

    /// Plain-English description of what the datum actually is at this
    /// site (e.g. "riverbed at the gauge post"), for display and for
    /// anyone calibrating a new sensor.
    let datumDescription: String

    /// The risk thresholds that apply at this specific site.
    let thresholds: Threshold
}
