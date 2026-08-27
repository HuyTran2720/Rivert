//
//  WeatherCard.swift
//  Flood-Detection
//
//  WHAT: The 364x67 glass pill under the date row. Shows the current
//        3-hour BMKG slot large, then the next four as a strip.
//
//  WHY:  Weather is context, never a warning — nothing here feeds
//        riskState. It answers "is more water coming?", which the
//        sensor alone cannot.
//

import SwiftUI

/// One column of the card, already resolved for display.
struct WeatherSlotDisplay: Identifiable, Equatable {
    let id: Date
    /// Hour of day in site-local time, e.g. "15".
    let hourLabel: String
    let tempC: Int
    let description: String
    let icon: WeatherIcon
}

struct WeatherCard: View {

    /// Index 0 is the current slot; 1...4 are the next four. Fewer than
    /// five is rendered as-is rather than padded — a short forecast is
    /// better shown short than faked.
    let slots: [WeatherSlotDisplay]
    var status: SafetyStatus = .safe

    private var current: WeatherSlotDisplay? { slots.first }
    private var upcoming: [WeatherSlotDisplay] { Array(slots.dropFirst()) }

    // Same rule as the date's accent: white for danger since the accent
    // color there is too dark to read against the red gradient.
    private var accentColor: Color {
        status == .danger ? .white : Color.statusAccent(for: status)
    }

    var body: some View {
        HStack(spacing: 12) {
            currentBlock
            Spacer(minLength: 8)
            upcomingStrip
        }
        .padding(.horizontal, 16)
        .frame(width: 364, height: 67)
        // Matched to the Figma Glass spec as far as the API allows:
        // fill FFFFFF @ 10% -> tint, corner radius 14, and Frost 4
        // (near zero) -> .clear rather than the heavily frosted
        // .regular. Refraction/Depth/Dispersion/Light/Splay have no
        // SwiftUI equivalent - the material is system-defined.
        .glassEffect(
            .clear.tint(Color.white.opacity(0.10)),
            in: .rect(cornerRadius: 14)
        )
    }

    // MARK: - Now

    @ViewBuilder
    private var currentBlock: some View {
        HStack(spacing: 8) {
            Image(current?.icon.systemImageName ?? WeatherIcon.cloudy.systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .opacity(current == nil ? 0.35 : 1)

            VStack(alignment: .leading, spacing: 0) {
                Text(current.map { "\($0.tempC)°" } ?? "--°")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(accentColor)
                Text(current?.description ?? "No forecast")
                    .font(.bodyFD2)
                    .foregroundStyle(accentColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    // MARK: - Next four

    private var upcomingStrip: some View {
        HStack(spacing: 14) {
            ForEach(upcoming) { slot in
                VStack(spacing: 1) {
                    Text(slot.hourLabel)
                        .font(.bodyFD3)
                        .foregroundStyle(accentColor)
                    Image(slot.icon.systemImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                .frame(width: 32)
            }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.softCyan, .softMint],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()

        WeatherCard(slots: [
            .init(id: .now, hourLabel: "9", tempC: 19,
                  description: "Sunny", icon: .sunny),
            .init(id: .now.addingTimeInterval(3600 * 3), hourLabel: "12",
                  tempC: 21, description: "Partly Cloudy", icon: .cloudy),
            .init(id: .now.addingTimeInterval(3600 * 6), hourLabel: "15",
                  tempC: 22, description: "Cloudy", icon: .cloudy),
            .init(id: .now.addingTimeInterval(3600 * 9), hourLabel: "18",
                  tempC: 20, description: "Light Rain", icon: .rain),
            .init(id: .now.addingTimeInterval(3600 * 12), hourLabel: "21",
                  tempC: 19, description: "Thunderstorm", icon: .storm),
        ])
    }
}
