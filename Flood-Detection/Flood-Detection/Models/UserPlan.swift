//
//  UserPlan.swift
//  Flood-Detection
//
//  WHAT: What the app is telling a specific user to actually do right now,
//        and how long they have to do it.
//
//  WHY:  A risk state and a number in millimetres don't tell someone what
//        to physically do. This is the translation from "riskState = act"
//        into concrete steps ("move the car", "unplug the fridge") and a
//        prep time budget, which is the whole point of the app for a
//        person standing in their kitchen.
//
//  USED BY: DashboardController, DashboardView
//
//  STATUS: Implemented as plain data. The actual action lists per
//          RiskState/site are not decided yet — see TODO.
//

import Foundation

/// A concrete set of instructions for the user, generated from the current
/// risk state.
struct UserPlan: Identifiable, Codable, Equatable {
    let id: UUID

    /// Which risk state this plan corresponds to.
    let riskState: RiskState

    /// Plain-language steps for the user to take, in priority order.
    // TODO: decide whether these come from a bundled config per site/risk
    // state, or are generated dynamically based on timeToThreshold.
    let actions: [String]

    /// How long the user realistically has to complete these actions
    /// before the situation escalates, in minutes.
    let prepTimeMinutes: Int
}
