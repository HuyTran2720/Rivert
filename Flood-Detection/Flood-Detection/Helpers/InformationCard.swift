//
//  DashboardCard.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 19/08/26.
//

import SwiftUI

struct InformationCard: View {
    let status: SafetyStatus
    
    
    var body: some View {
        ZStack {
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
                VStack {
                    Text("Rate of Water Rise")
                        .font(.headingFD2)
                        .foregroundColor(backgroundColor)
                        .bold()
                    HStack{
                        Text("Rising Fast")
                        Image(systemName:"arrow.up")
                    }
                            .padding(10)
                            .foregroundColor(.white)
                            .background(backgroundColor)
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
