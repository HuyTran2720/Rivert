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
    var badgeCornerRadius: CGFloat = 24
    var mainCornerRadius: CGFloat = 50
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
                .fill(LinearGradient(
                    colors: [.white, backgroundColor],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: 400, height: 440)

            HStack {
                DangerPhase()
                WaterLevelCard(currentLevel: currentLevel, range: 0...3000)
                    .frame(width: 150, height: 225)

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
            .padding(.top, 70)   // pushes content below the notch
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
    InformationCard(status: .caution, currentLevel: 2000, rateValue: "5", trend: .risingFast)
}
