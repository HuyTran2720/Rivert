//
//  PrimaryButton.swift
//  Flood-Detection
//
//  WHAT: The app's primary call-to-action button style (e.g. "I've done
//        this", "Continue" in onboarding).
//
//  WHY:  A single shared button so every screen's primary action looks
//        and behaves the same, styled from DesignSystem tokens once
//        those are decided.
//
//  USED BY: OnboardingView, DashboardView (once built)
//
//  STATUS: Placeholder. Behaves like a plain Button; no DesignSystem
//          styling applied yet — tokens are empty.
//

import SwiftUI

/// Placeholder. Will become the app's styled primary button, once
/// DesignSystem tokens are decided.
struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
    }
}

#Preview {
    PrimaryButton(title: "Continue") {}
}
