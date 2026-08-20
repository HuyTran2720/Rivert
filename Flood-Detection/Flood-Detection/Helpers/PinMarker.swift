//
//  PinMarker.swift
//  Flood-Detection
//
//  Created on 18/08/26.
//

import UIKit
import SwiftUI

struct PinMarker {

    static let circleSize: CGFloat = 40
    static let borderWidth: CGFloat = 4
    static let pointerHeight: CGFloat = 10

    /// Creates a speech-bubble pin marker image for the given status.
    static func image(for status: SafetyStatus) -> UIImage {
        let totalWidth = circleSize + borderWidth
        let totalHeight = circleSize + borderWidth + pointerHeight
        let size = CGSize(width: totalWidth, height: totalHeight)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let ctx = context.cgContext
            let center = CGPoint(x: totalWidth / 2, y: (circleSize + borderWidth) / 2)
            let radius = circleSize / 2

            // --- White border circle ---
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.addArc(center: center, radius: radius + borderWidth / 2,
                       startAngle: 0, endAngle: .pi * 2, clockwise: false)
            ctx.fillPath()

            // --- Bottom pointer (white) ---
            let pointerBase: CGFloat = 12
            let bottomOfCircle = center.y + radius + borderWidth / 2
            ctx.move(to: CGPoint(x: center.x - pointerBase / 2, y: bottomOfCircle - 2))
            ctx.addLine(to: CGPoint(x: center.x, y: bottomOfCircle + pointerHeight))
            ctx.addLine(to: CGPoint(x: center.x + pointerBase / 2, y: bottomOfCircle - 2))
            ctx.closePath()
            ctx.fillPath()

            // --- Colored circle fill ---
            ctx.setFillColor(status.pinTintColor.cgColor)
            ctx.addArc(center: center, radius: radius,
                       startAngle: 0, endAngle: .pi * 2, clockwise: false)
            ctx.fillPath()

            // --- SF Symbol icon ---
            let iconName: String
            switch status {
            case .danger:  iconName = "light.beacon.max"
            case .caution: iconName = "exclamationmark.triangle"
            case .safe:    iconName = "checkmark"
            }

            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
            if let symbol = UIImage(systemName: iconName, withConfiguration: config)?
                .withTintColor(.white, renderingMode: .alwaysOriginal) {
                let iconRect = CGRect(
                    x: center.x - symbol.size.width / 2,
                    y: center.y - symbol.size.height / 2,
                    width: symbol.size.width,
                    height: symbol.size.height
                )
                symbol.draw(in: iconRect)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 24) {
        ForEach(SafetyStatus.allCases, id: \.self) { status in
            VStack(spacing: 8) {
                Image(uiImage: PinMarker.image(for: status))
                    .interpolation(.high)
                Text(status.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    .padding()
}
