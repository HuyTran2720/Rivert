//
//  TimeCard2.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 24/08/26.
//
//
//  TimeCard.swift
//  Flood-Detection
//

import SwiftUI

struct TimeCard: View {
    let status: SafetyStatus
    let timeToBank: String   

    var body: some View {
        VStack(spacing: 6) {
            Text("River Overflow")
                .font(.bodyFD3)
                .foregroundStyle(Color.white)

            Text(statusText)
                .font(.headingFD2)
                .bold()
                .foregroundStyle(Color.white)
        }
        .padding(.vertical, 12)
        .frame(width: 189, height: 59)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(backgroundColor)
        )
    }

    private var statusText: String {
        switch status {
        case .danger: return "Flood Detected"
        case .caution: return "< \(timeToBank)"
        case .safe: return "No flood detected"
        }
    }

    private var backgroundColor: Color {
        Color.statusAccent(for: status)
    }

}

#Preview {
    VStack(spacing: 16) {
        TimeCard(status: .danger, timeToBank: "30 Minutes")
        TimeCard(status: .caution, timeToBank: "30 Minutes")
        TimeCard(status: .safe, timeToBank: "30 Minutes")
    }
    .padding()
    .background(Color.gray)
}
