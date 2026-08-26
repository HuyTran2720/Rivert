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
    var statusAnimation: String {
        switch status {
            case .danger: return "danger-rat"
            case .caution: return "caution-rat"
            case .safe: return "AA"
        }
    }
    var body: some View {
        VStack {
            LottieView(animation: .named(statusAnimation))
                .playing(loopMode: .loop) // Plays automatically and loops
                .frame(width: 250, height: 250) // Scale to fit your UI
        }
    }
}

#Preview {
    LottieMascot(status: .danger)
}
