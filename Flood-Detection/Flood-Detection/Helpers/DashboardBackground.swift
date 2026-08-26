//
//  DashboardBackground.swift
//  Flood-Detection
//
//  Created by RyanMFDR on 26/08/26.
//

import SwiftUI

struct DashboardBackground: View {
    var status : SafetyStatus
    
    var body: some View {
        ZStack(alignment:.top) {
            switch status {
                case .safe:
                    Image(.backgroundCitySafe)
                        .resizable()
                        .scaledToFit()
                            
                case .caution:
                    Image(.backgroundCityCautious)
                        .resizable()
                        .scaledToFit()
                            
                case .danger:
                    Image(.backgroundCityDanger)
                        .resizable()
                        .scaledToFit()
            }
        }
        .animation(.easeInOut, value: status)
    }
}

#Preview {
    DashboardBackground(status: .safe)

}
