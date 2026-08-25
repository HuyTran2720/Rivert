//
//  TimeCard2.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 24/08/26.
//

import SwiftUI

struct TimeCard: View {
    
    let status: SafetyStatus

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: 180, height: 67.5)
                .cornerRadius(8)
            Rectangle()
                .fill(backgroundColor)
                .frame(width: 165, height: 52.5)
                .cornerRadius(8)
            
            VStack(spacing: 4) {
                Text("River Overflow")
                    .font(.system(size: 10.5, weight: .regular))
                    .foregroundColor(.white)
                
                Text(mainText)
                    .font(.system(size: 13.4, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
    
    private var mainText: String {
        switch status {
        case .danger: return "Flood Detected"
        case .caution: return "< 30 Minutes"
        case .safe: return "No flood detected"
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .danger: return .redTitle
        case .caution: return Color.orange // Using standard orange as it matches the mockup best
        case .safe: return .secondaryFD
        }
    }
}

#Preview {
    VStack {
        TimeCard(status: .caution)
        TimeCard(status: .danger)
        TimeCard(status: .safe)
    }
}
