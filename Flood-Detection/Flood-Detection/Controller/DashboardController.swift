////
////  DashboardController.swift
////  Flood-Detection
////
////  WHAT: Drives the main dashboard screen — holds the current reading,
////        computed rate, risk state, and active user plan, and will
////        subscribe to a ReadingSource to keep them updated.
////
////  WHY:  DashboardView needs somewhere to get its state from that isn't
////        itself, so the view can stay a dumb, previewable placeholder
////        while this holds the actual logic (once built) tying
////        RateCalculator and ThresholdEvaluator to a live ReadingSource.
////
////  USED BY: DashboardView (once wired)
////
////  STATUS: Scaffolding only. Properties exist so the view has something
////          to bind to; none of the loading/subscription logic is
////          implemented yet.
////
//
//import Foundation
//
//@Observable
//final class DashboardController {
//
//    private let readingSource: any ReadingSource
//
//    /// Most recent reading received. Nil until load() has run.
//    var latestReading: Reading?
//
//    /// Rate of rise in mm/hour, from RateCalculator. Nil if not enough
//    /// data yet.
//    var rateMMPerHour: Double?
//
//    /// Current classification from ThresholdEvaluator.
//    var riskState: RiskState = .normal
//
//    /// What the user should be doing right now, if anything.
//    var userPlan: UserPlan?
//
//    init(readingSource: any ReadingSource) {
//        self.readingSource = readingSource
//    }
//
//    // TODO: implement — load the latest reading and history, compute rate
//    // via RateCalculator, compute riskState via ThresholdEvaluator, then
//    // subscribe to readingSource.stream to keep all of the above updated
//    // live.
//    func load() async {
//    }
//}
