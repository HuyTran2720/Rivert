//
//  SafetyStatusCard.swift
//  Flood-Detection
//
//  Created by RyanMFDR on 14/08/26.
//

import SwiftUI

enum SafetyStatusCardSize {
    case small, medium, large

    var iconSize: CGSize {
        switch self {
        case .small:  return CGSize(width: 28, height: 23)
        case .medium: return CGSize(width: 42, height: 35)
        case .large:  return CGSize(width: 56, height: 47)
        }
    }

    var titleFont: Font {
        switch self {
        case .small:  return .subheadline
        case .medium: return .headline
        case .large:  return .title3
        }
    }

    var messageFont: Font {
        switch self {
        case .small:  return .caption
        case .medium: return .bodyFD2
        case .large:  return .body
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small:  return 16
        case .medium: return 24
        case .large:  return 32
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .small:  return 14
        case .medium: return 18
        case .large:  return 22
        }
    }

    var maxWidth: CGFloat {
        switch self {
        case .small:  return 220
        case .medium: return 280
        case .large:  return 340
        }
    }
}

struct SafetyStatusCard: View {
    let status: SafetyStatus
    var size: SafetyStatusCardSize = .medium

    @State private var isPulsing = false

    var body: some View {
            VStack(alignment: .center, spacing: 4) {
                HStack {
                    Group {
                        if status == .safe {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(titleColor)
                        } else {
                            Image(imageResource)
                                .resizable()
                        }
                    }
                    .frame(width: iconSize.width, height: iconSize.height)
                    .zIndex(1)
                    .padding(.bottom, status == .safe ? 0 : 8)
                    Text(title)
                        .font(size.titleFont)
                        .foregroundStyle(titleColor)
                        .fontWeight(.bold)
                }
                Text(message)
                    .font(size.messageFont)
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
            }
            .frame(maxWidth: size.maxWidth, alignment: .center)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 200, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 200, style: .continuous)
                    .stroke(outlineColor, lineWidth: 2)
                    .shadow(color: outlineColor.opacity(glowOpacity), radius: glowRadius)
                    .shadow(color: outlineColor.opacity(glowOpacity * 0.6), radius: glowRadius * 2)
            )
            .scaleEffect(isPulsing ? 1.03 : 1.0)
            .onAppear { updatePulsing(for: status) }
            .onChange(of: status) { _, newStatus in updatePulsing(for: newStatus) }
        }

    private func updatePulsing(for status: SafetyStatus) {
        if status == .danger {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPulsing = false
            }
        }
    }

    private var iconSize: CGSize {
        guard status == .safe else { return size.iconSize }
        return CGSize(width: size.iconSize.width * 0.55, height: size.iconSize.height * 0.55)
    }

    private var glowRadius: CGFloat {
        switch status {
        case .safe: return 6
        case .caution: return 10
        case .danger: return 18
        }
    }

    private var glowOpacity: Double {
        switch status {
        case .safe: return 0.5
        case .caution: return 0.65
        case .danger: return 0.95
        }
    }

    private var title: String {
        switch status {
        case .safe: return "SAFE"
        case .caution: return "CAUTION"
        case .danger: return "DANGER"
        }
    }
    
    private var message: String {
        switch status {
        case .safe: return "River is within normal levels."
        case .caution: return "Higher flood risk is expected within the next hour. Be prepared!"
        case .danger: return "The river has overspilled. Avoid this area!"
        }
    }

    
    private var imageResource: ImageResource {
        switch status {
        case .safe: return .safeMark // fallback, harusnya nggak pernah kepakai
        case .caution: return .cautiousMark
        case .danger: return .dangerMark
        }
    }
    
    private var titleColor: Color {
        switch status {
        case .safe: return .greenTitle
        case .caution: return .yellowTitle
        case .danger: return .redTitle
        }
    }
    
    private var textColor: Color {
        switch status {
        case .safe: return .greenText
        case .caution: return .yellowText
        case .danger: return .redText
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .safe: return .greenBackground
        case .caution: return .yellowBackground
        case .danger: return .redBackground
        }
    }
    
    private var outlineColor: Color {
        switch status {
        case .safe: return .greenOutline
        case .caution: return .yellowOutline
        case .danger: return .redOutline
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SafetyStatusCard(status: .caution, size: .small)
        SafetyStatusCard(status: .caution, size: .medium)
        SafetyStatusCard(status: .caution, size: .large)
        SafetyStatusCard(status: .safe, size: .small)
        SafetyStatusCard(status: .safe, size: .medium)
        SafetyStatusCard(status: .safe, size: .large)
        SafetyStatusCard(status: .danger, size: .small)
        SafetyStatusCard(status: .danger, size: .medium)
        SafetyStatusCard(status: .danger, size: .large)
    }
    .padding()
}
