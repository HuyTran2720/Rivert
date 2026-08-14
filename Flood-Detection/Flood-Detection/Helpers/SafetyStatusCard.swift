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
        HStack(spacing: -10) {
            Image(imageResource)
                .resizable()
                .frame(width: 42, height: 35)
                .zIndex(1)
                .padding(.bottom,8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundStyle(titleColor)
                    .fontWeight(.bold)
                Text(message)
                    .font(.bodyFD2)
                    .foregroundStyle(textColor)
            }
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 200, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 200, style: .continuous)
                    .stroke(outlineColor, lineWidth: 2)
            )
        }
    }
        
    private var title: String {
        switch status {
        case .safe: return ""
        case .caution: return "CAUTION"
        case .danger: return "DANGER"
        }
    }
    
    private var message: String {
        switch status {
        case .safe: return ""
        case .caution: return "Higher flood risk is expected within the next hour. Be prepared!"
        case .danger: return "Floodwater is reaching homes and roads may no longer be accessible."
        }
    }
    
    private var imageResource: ImageResource {
        switch status {
        case .safe: return .cautiousMark // fallback, harusnya nggak pernah kepakai
        case .caution: return .cautiousMark
        case .danger: return .dangerMark
        }
    }
    
    private var titleColor: Color {
        switch status {
        case .safe: return .yellowTitle
        case .caution: return .yellowTitle
        case .danger: return .redTitle
        }
    }
    
    private var textColor: Color {
        switch status {
        case .safe: return .yellowText
        case .caution: return .yellowText
        case .danger: return .redText
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .safe: return .yellowBackground
        case .caution: return .yellowBackground
        case .danger: return .redBackground
        }
    }
    
    private var outlineColor: Color {
        switch status {
        case .safe: return .yellowOutline
        case .caution: return .yellowOutline
        case .danger: return .redOutline
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SafetyStatusCard(status: .caution)
        SafetyStatusCard(status: .danger)
    }
    .padding()
}
