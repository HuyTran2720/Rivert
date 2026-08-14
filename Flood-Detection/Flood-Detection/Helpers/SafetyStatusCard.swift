//
//  SafetyStatusView.swift
//  Flood-Detection
//
//  Created by RyanMFDR on 14/08/26.
//

import SwiftUI

struct SafetyStatusView : View {
    var body: some View {
        HStack {
            
            VStack {
                Text("CAUTION")
                    .foregroundStyle(Color.yellowTitle)
                    .fontWeight(.bold)
                Text("Higher flood risk is expected within the next hour. Be prepared!")
                    .foregroundStyle(Color.yellowText)
            }
        }
        .padding()
        .background(Color.yello)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    SafetyStatusView()
}
