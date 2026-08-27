//
//  Untitled.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 26/08/26.
//

import SwiftUI
import Lottie // 1. Import the Lottie module

struct LottieMascot: View {
    let status: SafetyStatus
    var AnimationName: String {
        switch status {
            case .danger: return "danger-rat"
            case .caution: return "caution-rat"
            case .safe: return "safe-rat"
        }
        
    }
    var body: some View {
        switch status {
        case .danger:
            LottieView(animation: .named("danger-rat"))
                .playing(loopMode: .loop)
                .frame(width: 250, height: 250)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top,10)
        case .caution:
            LottieView(animation: .named("caution-rat"))
                .playing(loopMode: .loop)
                .frame(width: 300, height: 300)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom,110)
        case .safe:
            LottieView(animation: .named("safe-rat"))
                .playing(loopMode: .loop)
                .frame(maxWidth: 200, maxHeight: 200)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom,140)
        }
    }
}

#Preview {
    ZStack {
        DashboardBackground(status:.danger)
        LottieMascot(status: .danger)
    }
}
