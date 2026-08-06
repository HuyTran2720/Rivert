//
//  Threshold.swift
//  Flood-Detection
//
//  WHAT: The three water levels that matter for a site: where local
//        drainage stops coping, and Indonesia's standard "siaga" (alert)
//        and "awas" (danger/evacuate) flood status levels.
//
//  WHY:  RiskState and the whole point of this app — telling someone how
//        much time they have — depend on comparing the current level and
//        rate of rise against these three numbers. Keeping them as one
//        type per Site avoids the same three magic numbers being copied
//        into every calculation.
//
//  USED BY: ThresholdEvaluator, Site, DashboardController
//
//  STATUS: Implemented as plain data. Real values per site are not yet
//          decided/sourced.
//

import Foundation

/// Risk thresholds for a single site, in millimetres above the site datum.
struct Threshold: Codable, Equatable {

    /// Indonesia's official "siaga" (standby/alert) flood status level.
    let siagaMM: Double

    /// Indonesia's official "awas" (danger — evacuate) flood status level.
    let awasMM: Double

    /// The level at which local drainage is known to stop coping and
    /// water starts backing up into streets/homes. Distinct from awasMM
    /// because it's a local engineering fact, not an official status band.
    let drainageFailureMM: Double
}
