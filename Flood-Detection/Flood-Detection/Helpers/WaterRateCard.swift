//
//  WaterRateCard.swift
//  Flood-Detection
//
//  Created by RyanMFDR on 18/08/26.
//

import SwiftUI

struct WaterRateCard: View {
    var value: String = "5"
    var status: SafetyStatus = .safe

    private var accentColor: Color {
        Color.statusAccent(for: status)
    }

    private var glowColor: Color {
        switch status {
        case .safe:    return .softCyan
        case .caution: return .cardAmber
        case .danger:  return .cardRed
        }
    }

    private let outerRadius: CGFloat = 55
    private let innerRadius: CGFloat = 42
    
    private let dotConfigs: [(size: CGFloat, startAngle: Double, duration: Double, clockwise: Bool, isInner: Bool)] = [
        (size: 5, startAngle: 20,  duration: 6.0, clockwise: true,  isInner: false),
        (size: 6, startAngle: 95,  duration: 8.5, clockwise: false, isInner: true),
        (size: 3, startAngle: 160, duration: 5.5, clockwise: true,  isInner: false),
        (size: 3, startAngle: 230, duration: 9.5, clockwise: false, isInner: true),
        (size: 8, startAngle: 300, duration: 7.0, clockwise: true,  isInner: false)
    ]

    @State private var drift: [Double] = Array(repeating: 0, count: 5)

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.primaryFD)
                .frame(width: 110, height: 110)
                .shadow(color: glowColor.opacity(1), radius: 12, x: 0, y: 4)

            //the small dots (there's slow moving animation)
            ForEach(0..<dotConfigs.count, id: \.self) { i in
                let config = dotConfigs[i]
                let angle = config.startAngle + drift[i]
                let radius = config.isInner ? innerRadius : outerRadius

                Circle()
                    .fill(Color.primaryFD)
                    .zIndex(1)
                    .overlay(
                        Circle().fill(accentColor)
                    )
                    .frame(width: config.size, height: config.size)
                    .offset(
                        x: radius * cos(angle * .pi / 180),
                        y: radius * sin(angle * .pi / 180)
                    )
            }

            Circle()
                .fill(Color.white)
                .frame(width: 84, height: 84)
                .shadow(color: glowColor.opacity(1), radius: 12, x: 0, y: 4)

            VStack(spacing: 2) {
                Text(value)
                    .font(.headingFD1)
                    .foregroundStyle(accentColor)
                Text("mm/min")
                    .font(.bodyFD3)
                    .foregroundStyle(accentColor)
            }
        }
        .onAppear {
            for i in dotConfigs.indices {
                let config = dotConfigs[i]
                let targetDrift: Double = config.clockwise ? 360 : -360
                withAnimation(
                    .linear(duration: config.duration)
                    .repeatForever(autoreverses: false)
                ) {
                    drift[i] = targetDrift
                }
            }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        WaterRateCard(status: .safe)
        WaterRateCard(status: .caution)
        WaterRateCard(status: .danger)
    }
    .padding()
}
