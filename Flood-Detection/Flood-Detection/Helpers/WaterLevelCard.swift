//
//  WaterLevelCard.swift
//  Flood-Detection
//
//  Created by RyanMFDR on 18/08/26.
//

import SwiftUI
import SpriteKit
import CoreMotion
import Combine

// MARK: - Wave Shape

struct WaveShape: Shape {
    var offset: Angle
    var percent: Double     // 0.0 (empty) ... 1.0 (full)
    var amplitude: CGFloat = 6

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(offset.degrees, percent) }
        set {
            offset = Angle(degrees: newValue.first)
            percent = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waveHeight = amplitude
        let yOffset = CGFloat(1 - percent) * (rect.height - waveHeight * 2) + waveHeight
        let startAngle = offset
        let endAngle = offset + Angle(degrees: 360)
        let wavelength = rect.width

        path.move(to: CGPoint(x: 0, y: yOffset))
        stride(from: startAngle.degrees, through: endAngle.degrees, by: 5).forEach { deg in
            let x = CGFloat((deg - startAngle.degrees) / 360) * wavelength
            let sine = sin(Angle(degrees: deg).radians)
            let y = yOffset + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - WaterLevel Component


struct WaterLevel: View {
    var currentLevel: Float
    var range: ClosedRange<Float> = 0...100

    @State private var waveOffset1 = Angle(degrees: 0)
    @State private var waveOffset2 = Angle(degrees: 180)

    private var percent: Double {
        let clamped = min(max(currentLevel, range.lowerBound), range.upperBound)
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return Double((clamped - range.lowerBound) / span)
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let capsuleShape = Capsule()

            ZStack {
                capsuleShape
                    .fill(.ultraThinMaterial)

                capsuleShape
                    .fill(Color.primaryFD.opacity(0.15))

                WaveShape(offset: waveOffset2, percent: percent, amplitude: height * 0.02)
                    .fill(Color.secondaryFD.opacity(0.7))
                    .frame(width: width, height: height)

                WaveShape(offset: waveOffset1, percent: percent, amplitude: height * 0.025)
                    .fill(Color.terniaryFD)
                    .frame(width: width, height: height)

                capsuleShape
                    .fill(
                        LinearGradient(
                            colors: [Color.primaryFD.opacity(0.35), Color.primaryFD.opacity(0)],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )

                    capsuleShape
                    .stroke(Color.secondaryFD.opacity(0.5), lineWidth: 2)

                // Inner shadow — gives the glass rim depth/concavity
                capsuleShape
                    .stroke(Color.black.opacity(0.25), lineWidth: 6)
                    .blur(radius: 4)
                    .offset(y: 2)
                    .mask(capsuleShape.fill(LinearGradient(
                        colors: [.black, .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )))
                    .clipShape(capsuleShape)
            }
            .clipShape(capsuleShape)
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    waveOffset1 = Angle(degrees: 360)
                }
                withAnimation(.linear(duration: 4.5).repeatForever(autoreverses: false)) {
                    waveOffset2 = Angle(degrees: -360)
                }
            }
            .animation(.easeInOut(duration: 0.8), value: percent)
        }
    }
}
// MARK: - WaterLevelCard with Height Pointer

struct WaterLevelCard: View {
    var currentLevel: Float
    var range: ClosedRange<Float> = 0...100
    var unit: String = "mm"

    private var percent: Double {
        let clamped = min(max(currentLevel, range.lowerBound), range.upperBound)
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return Double((clamped - range.lowerBound) / span)
    }

    var body: some View {
        HStack(spacing: 8) {
            WaterLevel(currentLevel: currentLevel, range: range)

            GeometryReader { geo in
                let height = geo.size.height
                // 0% = bottom, 100% = top, so flip the y position
                let pointerY = height * (1 - CGFloat(percent))

                ZStack(alignment: .topLeading) {
                    // pointer line
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: pointerY))
                        path.addLine(to: CGPoint(x: 14, y: pointerY))
                    }
                    .stroke(Color(red: 0.20, green: 0.55, blue: 0.58), lineWidth: 2)

                    Text("\(Int(currentLevel)) \(unit)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.20, green: 0.55, blue: 0.58))
                        .fixedSize()
                        .position(x: 32, y: pointerY)
                }
                .animation(.easeInOut(duration: 0.8), value: percent)
            }
            .frame(width: 60)
        }
    }
}

#Preview {
    WaterLevelCard(currentLevel: 2.0, range: 0...4)
        .frame(width: 200, height: 300)
}


