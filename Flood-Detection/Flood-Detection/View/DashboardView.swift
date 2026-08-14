//
//  DashboardView.swift
//  Flood-Detection
//
//  Created by dhita alfatrah on 13/08/26.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient.backgroundGradient)
                .ignoresSafeArea()
            
            VStack {
                VStack(alignment: .leading, spacing: 25) {
                    HStack {
                        Text("Thu, 6 August")
                            .font(.bodyFD2)
                        
                        Spacer()
                        
                        Text("Location")
                    }
                    HStack(spacing: 15) {
                        Text("Icon")
                        Text("Keterangan")
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 30)
                
                Spacer()
                Spacer()
                
                Text("Background Image")
                
                Spacer()
                
                Text("Time")
                    .padding(.bottom, 10)
                Spacer()
                
                HStack {
                    Text("Water Level")
                    
                    Spacer()
                    
                    Text("Rate of Water Rise")
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
            
        }
    }
}

#Preview {
    DashboardView()
}
