//
//  DashboardCard.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 19/08/26.
//

import SwiftUI

struct InformationCard: View {
    let status: SafetyStatus
    let currentStatus: SafetyStatus = .caution
    
    
    var body: some View {
        Spacer()
        ZStack(alignment:.center) {
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
                WaterLevelCard(currentLevel: 2.0, range: 0...4)
                    .frame(width: 150, height: 225)

                VStack (alignment:.center, spacing: 30){
                    Text("Rate of Water Rise")
                        .font(.bodyFD2)
                        .foregroundColor(.yellow)
                        .bold()
                    WaterRateCard()
                        HStack {
                        Text(currentStatus.rawValue)
                                .font(.bodyFD2)
                                .bold()
                        Image(systemName: "arrow.up")
                    }
                    .padding(5)
                    .foregroundColor(.white)
                    .background(.yellow)
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

}

#Preview {
    InformationCard(status:.caution)
}
