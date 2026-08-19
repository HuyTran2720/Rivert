//
//  SafetyStatusCard.swift
//  Flood-Detection
//
//  Created by RyanMFDR on 14/08/26.
//

import SwiftUI

struct SafetyStatusCard: View {
    let status: SafetyStatus

    
    var body: some View {
            VStack(alignment: .center, spacing: 4) {
                HStack {
                    Image(imageResource)
                        .resizable()
                        .frame(width: 42, height: 35)
                        .zIndex(1)
                        .padding(.bottom,8)
                    Text(title)
                        .foregroundStyle(titleColor)
                        .fontWeight(.bold)
                }
                Text(message)
                    .font(.bodyFD2)
                    .foregroundStyle(textColor)
            }
            .frame(width: 300, alignment: .center)
            .frame(minHeight: 40, alignment: .center)
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 200, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 200, style: .continuous)
                    .stroke(outlineColor, lineWidth: 2)
            )
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
        case .safe: return "it's safe to leave now, stay safe!"
        case .caution: return "Higher flood risk is expected within the next hour. Be prepared!"
        case .danger: return "Floodwater is reaching homes and roads may no longer be accessible."
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
        SafetyStatusCard(status: .caution)
        SafetyStatusCard(status: .danger)
        SafetyStatusCard(status: .safe)
    }
    .padding()
}
