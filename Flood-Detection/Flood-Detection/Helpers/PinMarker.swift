//
//  PinMarker.swift
//  Flood-Detection
//
//  Created on 18/08/26.
//
//  A reusable circular pin marker component for map annotations.
//  Renders a circle with a light-tinted fill, a colored border,
//  and a warning icon centered inside — all driven by status.
//

import UIKit
import SwiftUI

// MARK: - PinMarker

/// Generates circular pin marker images for map annotations.
/// Each pin has a light-tinted background, a colored border, and a
/// warning icon centered inside, all matching the given SafetyStatus.
struct PinMarker {

    /// The diameter of the pin circle in points.
    static let diameter: CGFloat = 40
    /// Creates a circular pin marker image for the given safety status.
    ///
    /// - Parameter status: Determines the pin's tint color and icon.
    /// - Returns: A rendered `UIImage` of the circular pin.
    static func image(for status: SafetyStatus) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let ctx = context.cgContext
            let inset: CGFloat = 1.5
            let circleRect = CGRect(x: inset, y: inset,
                                     width: diameter - 2 * inset,
                                     height: diameter - 2 * inset)

            // Light tinted circle background
            ctx.setFillColor(status.pinTintColor.withAlphaComponent(0.12).cgColor)
            ctx.fillEllipse(in: circleRect)

            // Colored border
            ctx.setStrokeColor(status.pinTintColor.withAlphaComponent(0.5).cgColor)
            ctx.setLineWidth(1.5)
            ctx.strokeEllipse(in: circleRect)

            // Warning icon centered inside the circle
            let iconImage = Self.iconImage(for: status)
            let iconWidth: CGFloat = 24
            let iconHeight: CGFloat = 20
            let iconRect = CGRect(
                x: (diameter - iconWidth) / 2,
                y: (diameter - iconHeight) / 2,
                width: iconWidth,
                height: iconHeight
            )
            iconImage.draw(in: iconRect)
        }
    }

    // MARK: - Helpers

    /// Returns the appropriate warning icon for the given safety status.
    private static func iconImage(for status: SafetyStatus) -> UIImage {
        switch status {
        case .danger:  return UIImage(resource: .dangerMark)
        case .caution: return UIImage(resource: .cautiousMark)
        case .safe:    return UIImage(resource: .safeMark)
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

