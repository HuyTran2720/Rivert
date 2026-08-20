//
//  MapAnnotationCard.swift
//  Flood-Detection
//
//  Created on 18/08/26.
//
//  A pill-shaped card for map annotations that displays a flood zone's name
//  and description. Appears directly on the map next to the pin when zoomed in.
//  Uses the same color system as SafetyStatusCard.
//

import SwiftUI

// MARK: - MapAnnotationCard

/// A pill-shaped info card that sits directly on the map beside a flood
/// zone pin. Shows the zone name (bold) and a short description, colored
/// by risk level using the same palette as SafetyStatusCard.
struct MapAnnotationCard: View {
    let title: String
    let message: String
    let status: SafetyStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headingFD2)
                .fontWeight(.bold)
                .foregroundStyle(titleColor)
            Text(message)
                .font(.bodyFD2)
                .foregroundStyle(textColor)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .frame(width:250,height:40)
        .padding(.vertical, 10)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(outlineColor, lineWidth: 1.5)
        )
    }

    // MARK: - Colors (same palette as SafetyStatusCard)

    private var titleColor: Color {
        switch status {
        case .safe:    return .greenTitle
        case .caution: return .yellowTitle
        case .danger:  return .redTitle
        }
    }

    private var textColor: Color {
        switch status {
        case .safe:    return .greenText
        case .caution: return .yellowText
        case .danger:  return .redText
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .safe:    return .greenBackground
        case .caution: return .yellowBackground
        case .danger:  return .redBackground
        }
    }

    private var outlineColor: Color {
        switch status {
        case .safe:    return .greenOutline
        case .caution: return .yellowOutline
        case .danger:  return .redOutline
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        MapAnnotationCard(
            title: "Tukad Mati River, Legian",
            message: "River water has overflowed onto nearby roads.",
            status: .caution
        )
        MapAnnotationCard(
            title: "Denpasar",
            message: "Urban flooding due to drainage overflow.",
            status: .danger
        )
        MapAnnotationCard(
            title: "Singaraja",
            message: "Minimal flood history.",
            status: .safe
        )
    }
    .padding()
}
