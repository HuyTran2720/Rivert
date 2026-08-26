//
//  SafetyStatusLegend.swift
//  Flood-Detection
//
//  Created on 19/08/26.
//
//  A simple map legend displaying the safety status levels.
//

import SwiftUI

// MARK: - Dashed Connector Line
struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

// MARK: - Threshold Cross Lines
struct ThresholdCrossLines: View {
    var height: CGFloat
    var colors: [Color]
    var verticalInset: CGFloat = 0
    var lineWidth: CGFloat = 1.5
    var dash: [CGFloat] = [4, 3]
    var opacity: Double = 0.6

    private let dotSize: CGFloat = 10
    private var rowPitch: CGFloat {
        (height - verticalInset * 2 - dotSize) / 2
    }

    var body: some View {
        VStack(spacing: rowPitch - dotSize) {
            ForEach(colors.indices, id: \.self) { i in
                DashedLine()
                    .stroke(colors[i], style: StrokeStyle(lineWidth: lineWidth, dash: dash))
                    .frame(height: dotSize)
            }
        }
        .padding(.top, verticalInset)
        .frame(height: height, alignment: .top)
        .opacity(opacity)
    }
}

// MARK: - Danger Phase Legend

struct DangerPhase: View {
    var dangerValue: Double = 21.2
    var cautionValue: Double = 10.5
    var safeValue: Double = 5.25
    var unit: String = "cm"
    var height: CGFloat = 205
    var verticalInset: CGFloat = 0

    private let labelBlockHeight: CGFloat = 34
    private let dotSize: CGFloat = 10
    private var rowPitch: CGFloat {
        (height - verticalInset * 2 - dotSize) / 2
    }

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            // Text labels
            VStack(alignment: .trailing, spacing: rowPitch - labelBlockHeight) {
                legendLabel("Danger", value: dangerValue, color: .redTitle)
                legendLabel("Caution", value: cautionValue, color: .yellowTitle)
                legendLabel("Safe", value: safeValue, color: .greenTitle)
            }
            .padding(.top, verticalInset - (labelBlockHeight - dotSize) / 2)

            // Vertical line and dots
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 2, height: height)
                    .padding(.vertical, 4)

                VStack(spacing: rowPitch - dotSize) {
                    dot(color: .redTitle)
                    dot(color: .yellowTitle)
                    dot(color: .greenTitle)
                }
                .padding(.top, verticalInset)
            }
        }

        .padding(.leading)
    }

    @ViewBuilder
    private func legendLabel(_ title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(title)
                .font(.headingFD3)
                .foregroundStyle(color)
            Text(formatted(value))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(height: labelBlockHeight, alignment: .trailing)
    }

    @ViewBuilder
    private func dot(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: dotSize, height: dotSize)
    }

    private func formatted(_ value: Double) -> String {
        let isWhole = value.truncatingRemainder(dividingBy: 1) == 0
        return String(format: isWhole ? "%.0f %@" : "%.1f %@", value, unit)
    }
}

#Preview {
    HStack(alignment: .top, spacing: 0) {
        DangerPhase(height: 225, verticalInset: 30)
        Capsule()
            .fill(Color.gray.opacity(0.15))
            .frame(width: 100, height: 225)
            .overlay(
                ThresholdCrossLines(
                    height: 225,
                    colors: [.redTitle, .yellowTitle, .greenTitle],
                    verticalInset: 30
                )
            )
    }
    .background(Color.white)
}
