//
//  SafetyStatusLegend.swift
//  Flood-Detection
//
//  Created on 19/08/26.
//
//  A simple map legend displaying the safety status levels.
//

import SwiftUI

struct DangerPhase: View {
    var body: some View {
        HStack(spacing: 5) {
            // Text labels
            VStack(alignment: .trailing, spacing: 45) {
                Text("Danger")
                    .font(.headingFD3)
                    .foregroundStyle(Color.redTitle)
                    .frame(height: 12)
                Text("Caution")
                    .font(.headingFD3)
                    .foregroundStyle(Color.yellowTitle)
                    .frame(height: 12)
                Text("Safe")
                    .font(.headingFD3)
                    .foregroundStyle(Color.greenTitle)
                    .frame(height: 12)
            }
            
            // Vertical line and dots
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 2, height: 200)
                    .padding(.vertical, 4)
                    
                VStack(spacing: 47) {
                    Circle().fill(Color.redTitle).frame(width: 10, height: 10)
                    Circle().fill(Color.yellowTitle).frame(width: 10, height: 10)
                    Circle().fill(Color.greenTitle).frame(width: 10, height: 10)
                }
            }
        }
        .padding()
        // Optional: add a background if needed, but it seems transparent in the original image.
        // .background(Color.white)
        // .cornerRadius(12)
        // .shadow(radius: 2)
    }
}

#Preview {
    DangerPhase()
}
