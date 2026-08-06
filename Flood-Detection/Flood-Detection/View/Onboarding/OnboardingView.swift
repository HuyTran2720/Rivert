//
//  OnboardingView.swift
//  Flood-Detection
//
//  WHAT: First-run flow for picking/configuring the site the user wants
//        to monitor.
//
//  WHY:  The dashboard can't show anything meaningful without a Site
//        (thresholds, sensor geometry) selected first. Placeholder while
//        both the onboarding UX and OnboardingController are designed.
//
//  USED BY: ContentView (not yet wired in)
//
//  STATUS: Placeholder. Text only.
//

import SwiftUI

/// Placeholder. Will become the first-run flow for selecting/configuring
/// a Site. Design not yet finalised.
struct OnboardingView: View {
    var body: some View {
        Text("Onboarding — placeholder")
    }
}

#Preview {
    OnboardingView()
}
