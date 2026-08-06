//
//  AlertController.swift
//  Flood-Detection
//
//  WHAT: Placeholder for whatever notifies the user when risk state
//        changes — push notification, local notification, in-app banner,
//        or some combination.
//
//  WHY:  Detecting risk (ThresholdEvaluator) and telling the user about it
//        are separate concerns. This file exists so that separation is
//        visible in the codebase even though the alerting mechanism
//        itself isn't decided yet.
//
//  USED BY: Nothing yet.
//
//  STATUS: Stub only. No UNUserNotificationCenter code, no push, no
//          persistence of "already alerted" state — all undecided.
//

import Foundation

/// Stand-in for the app's alerting mechanism. Not implemented.
final class AlertController {

    // TODO: decide the delivery mechanism (local notification vs. push
    // vs. in-app only) before implementing this.

    /// Will be called when DashboardController detects a RiskState change.
    /// Currently does nothing but throw.
    func notify(riskState: RiskState) async throws {
        throw NotImplementedError()
    }
}
