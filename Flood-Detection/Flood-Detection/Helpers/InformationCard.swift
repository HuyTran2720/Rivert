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

    var body: some View {
        ZStack(alignment: .top) {
            DashboardCardShape()
                .fill(LinearGradient.cardGradient(for: status))
                .frame(width: 400, height: 350)
                .cornerRadius(50)
            HStack(spacing:10) {
                VStack {
                    HStack {
                        DangerPhase(height: 225, verticalInset: 30)
                        WaterLevelCard(currentLevel: currentLevel, range: 0...21.2)
                            .frame(width: 150, height: 225)
                            .overlay(
                                ThresholdCrossLines(
                                    height: 225,
                                    colors: [.redTitle, .yellowTitle, .greenTitle],verticalInset: 30
                                ).frame(width: 71),
                                alignment: .leading
                            ).padding(.bottom,10)
                    }
                }

                VStack(alignment: .center, spacing: 30) {
                    Text("Rate of Water Rise")
                        .font(.bodyFD2)
                        .foregroundColor(backgroundColor)
                        .bold()
                    WaterRateCard(value: rateValue)
                    HStack {
                        Text(trend.WaterTrendName)
                            .font(.bodyFD2)
                            .bold()
                        Image(systemName: trend.WaterTrendIcon)
                    }
                    .padding(5)
                    .foregroundColor(.primaryFD)
                    .background(backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 200, style: .continuous))
                }
            }
            .padding(.top, 80)
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .safe: return .secondaryFD
        case .caution: return .yellowBackground
        case .danger: return .redBackground
        }
    }

    private var textColor: Color {
        switch status {
        case .safe: return .greenText
        case .caution: return .yellowText
        case .danger: return .redText
        }
    }
}

#Preview {
    InformationCard(status: .safe, currentLevel: 21, rateValue: "5", trend: .risingFast)
}
