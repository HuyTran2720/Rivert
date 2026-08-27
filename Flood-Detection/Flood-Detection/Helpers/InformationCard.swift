//
//  DashboardCard.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 19/08/26.
//

import SwiftUI

struct DashboardCardShape: Shape {
    var badgeWidth: CGFloat = 209
    var badgeHeight: CGFloat = 70
    var badgeCornerRadius: CGFloat = 10
    var mainCornerRadius: CGFloat = 23
    var mainTopInset: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let badgeX = (rect.width - badgeWidth) / 2
        let badgeRect = CGRect(x: badgeX, y: 0, width: badgeWidth, height: badgeHeight)
        path.addPath(Path(roundedRect: badgeRect, cornerRadius: badgeCornerRadius))

        let mainRect = CGRect(
            x: 0,
            y: mainTopInset,
            width: rect.width,
            height: rect.height - mainTopInset
        )
        path.addPath(Path(roundedRect: mainRect, cornerRadius: mainCornerRadius))

        return path
    }
}

struct InformationCard: View {
    let status: SafetyStatus
    var currentLevel: Float
    var rateValue: String
    var trend: WaterTrend
    var lastUpdated: String = "Updated 2 min ago"

    var body: some View {
        ZStack(alignment: .top) {
            DashboardCardShape()
                .fill(LinearGradient.cardGradient(for: status))
                .frame(width: 400, height: 350)
                .cornerRadius(50)

            HStack(alignment: .top, spacing: 5) {
                // MARK: - Left Column (River Water Level)
                VStack(alignment: .leading, spacing: 16) {
                    Text("River Water Level")
                        .font(.bodyFD1)
                        .foregroundColor(accentColor)
                        .bold()

                    WaterLevelCard(currentLevel: currentLevel, range: 0...21.2, status: status)
                        .frame(width: 190, height: 200)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading,20)

                // MARK: - Right Column (Rate of Water Rise)
                VStack(spacing: 16) {
                    VStack(alignment:.leading,spacing: 2) {
                        Text("Rate of Water Rise")
                            .font(.bodyFD1)
                            .foregroundColor(accentColor)
                            .bold()

                        Text("How fast the river water level is rising")
                            .font(.bodyFD3)
                            .foregroundColor(accentColor.opacity(0.5))
                            .multilineTextAlignment(.leading)
                    }

                    WaterRateCard(value: rateValue, status: status)

                    HStack {
                        Text(trend.WaterTrendName)
                            .font(.bodyFD2)
                            .bold()
                        Image(systemName: trend.WaterTrendIcon)
                    }
                    .padding(5)
                    .foregroundColor(.primaryFD)
                    .background(accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 200, style: .continuous))

                    VStack(alignment:.trailing,spacing: 2) {
                        Text("Measured by river sensor")
                        Text(lastUpdated)
                    }
                    .padding(.top,-5)
                    .font(.bodyFD2)
                    .foregroundColor(accentColor.opacity(0.8))
                    .multilineTextAlignment(.trailing)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.top, 80)
        }
    }

    private var accentColor: Color {
        Color.statusAccent(for: status)
    }
}

#Preview {
    InformationCard(status: .danger, currentLevel: 21, rateValue: "5", trend: .risingFast)
}
