//
//  InfoCardView.swift
//  Flood-Detection
//
//  WHAT: Reusable card container for a labelled stat (e.g. "Rate of rise:
//        120 mm/hr").
//
//  WHY:  Several dashboard stats will share the same card treatment.
//        Breaking it out now means the design team can settle its look
//        once, in one place.
//
//  USED BY: DashboardView (once built)
//
//  STATUS: Placeholder. No layout or styling yet — design not finalised.
//

import SwiftUI

/// Placeholder. Will become a generic labelled-stat card. Design not yet
/// finalised.
struct InfoCardView: View {
    var body: some View {
        Text("Info card — placeholder")
    }
}

#Preview {
    InfoCardView()
}
