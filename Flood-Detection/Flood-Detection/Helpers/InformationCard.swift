//
//  DashboardCard.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 19/08/26.
//

import SwiftUI

struct InformationCard: View {
    let status: SafetyStatus
    var currentLevel: Float = 0
    var rateValue: String = "0"
    var trend: waterTrend = .normal


    var body: some View {
        Spacer()
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(LinearGradient(
                    colors: [.white, backgroundColor],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: 400, height: 400)
                .cornerRadius(50)
            HStack {
                DangerPhase()
                WaterLevelCard(currentLevel: currentLevel, range: 0...3000)
                    .frame(width: 150, height: 225)

                VStack (alignment:.center, spacing: 30){
                    Text("Rate of Water Rise")
                        .font(.bodyFD2)
                        .foregroundColor(textColor)
                        .bold()
                    WaterRateCard(value: rateValue)
                    HStack {
                        Text(trend.rawValue)
                            .font(.bodyFD2)
                            .bold()
                        Image(systemName: trend.systemImageName)
                    }
                    .padding(5)
                    .foregroundColor(.white)
                    .background(textColor)
                    .clipShape(RoundedRectangle(cornerRadius: 200, style: .continuous))
                }
            }
        }
    }
    private var backgroundColor: Color {
        switch status {
        case .safe: return .greenBackground
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
    InformationCard(status:.caution, currentLevel: 2000, rateValue: "5", trend: .rising)
}
