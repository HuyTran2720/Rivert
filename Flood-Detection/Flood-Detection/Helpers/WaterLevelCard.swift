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
    var percent: Double
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

// MARK: - Pointer Tag Shape
// A rounded pill with a small triangular tail pointing left, used as the
// background for the level readout badge. Because it's applied via
// `.background()`, `rect` will exactly match the size of the Text it sits behind.

struct PointerTagShape: Shape {
    var cornerRadius: CGFloat = 8
    var tailWidth: CGFloat = 6
    var tailHeight: CGFloat = 10

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Pill body, inset from the left to leave room for the tail
        let bodyRect = CGRect(
            x: rect.minX + tailWidth,
            y: rect.minY,
            width: rect.width - tailWidth,
            height: rect.height
        )
        path.addRoundedRect(in: bodyRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        
        let midY = rect.midY
        var tail = Path()
        tail.move(to: CGPoint(x: bodyRect.minX, y: midY - tailHeight / 2))
        tail.addLine(to: CGPoint(x: rect.minX, y: midY))
        tail.addLine(to: CGPoint(x: bodyRect.minX, y: midY + tailHeight / 2))
        tail.closeSubpath()

        path.addPath(tail)
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
    var unit: String = "cm"
    var pointerColor: Color = Color(red: 0.8627450980392157, green: 0.4666666666666667, blue: 0.4666666666666667)

    private let badgeHeight: CGFloat = 22

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
                let pointerY = height * (1 - CGFloat(percent))

                ZStack(alignment: .topLeading) {
                    Text(String(format: "%.1f%@", currentLevel, unit))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryFD)
                        .padding(.leading, 12)
                        .padding(.trailing, 8)
                        .frame(height: badgeHeight)
                        .background(
                            PointerTagShape(cornerRadius: badgeHeight / 2, tailWidth: 6, tailHeight: 10)
                                .fill(pointerColor)
                        )
                        .fixedSize()
                        .offset(x: 0, y: pointerY - badgeHeight / 2)
                }
                .animation(.easeInOut(duration: 0.8), value: percent)
            }
            .frame(width: 70)
        }
    }
}

#Preview {
    WaterLevelCard(currentLevel: 2.8, range: 0...4)
        .frame(width: 200, height: 300)
        .padding()
        .background(Color.black.opacity(0.8))
}
