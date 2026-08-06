//
//  VerticalGaugeView.swift
//  Flood-Detection
//
//  WHAT: Reusable vertical gauge meant to show current water level
//        against the siaga/awas/drainage-failure thresholds at a glance.
//
//  WHY:  This is the single visual the whole app probably revolves around
//        — a fast, glanceable read of "how close are we". Broken out as
//        a shared component so it can be reused on the dashboard and
//        potentially the widget/Live Activity later.
//
//  USED BY: DashboardView (once built)
//
//  STATUS: Placeholder. No layout or drawing yet — design not finalised.
//

import SwiftUI

/// Placeholder. Will become a vertical fill gauge showing current level
/// against Threshold values. Design not yet finalised.
struct VerticalGaugeView: View {
    var body: some View {
        Text("Vertical gauge — placeholder")
    }
}

#Preview {
    VerticalGaugeView()
}
