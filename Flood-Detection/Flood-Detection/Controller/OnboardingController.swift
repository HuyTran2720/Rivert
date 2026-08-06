//
//  OnboardingController.swift
//  Flood-Detection
//
//  WHAT: Drives first-run onboarding — will hold the site the user
//        selects/configures and whether onboarding is complete.
//
//  WHY:  Before the dashboard means anything, the app needs to know which
//        Site (which river, which thresholds) the user cares about. This
//        holds that in-progress state while onboarding UI is built out.
//
//  USED BY: OnboardingView (once wired)
//
//  STATUS: Scaffolding only. Empty properties + TODOs — the onboarding
//          flow itself (how a Site gets chosen or created, whether it's
//          persisted) is not designed yet.
//

import Foundation

@Observable
final class OnboardingController {

    /// The site the user has picked/configured so far, if any.
    var selectedSite: Site?

    /// Whether the user has finished onboarding.
    var isComplete: Bool = false

    // TODO: decide how a Site is chosen (pick from a known list? manual
    // entry?) and whether the result gets persisted anywhere — no
    // persistence layer exists in this project yet by design.
}
