//
//  DashboardView.swift
//  Flood-Detection
//
//  Created by dhita alfatrah on 13/08/26.
//

import SwiftUI
import FirebaseFirestore

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    //Fot Date
    private var currentFormattedDate: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, d MMMM"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter.string(from: Date())
        }
    
    var body: some View {
        NavigationStack {
            ZStack() {
                //Background Color
                Rectangle()
                    .fill(LinearGradient.backgroundGradient)
                    .ignoresSafeArea()
                
                //Background Image
                VStack(alignment:.center,spacing:0) {
                    Image(.townBuilding)
                        .padding(.bottom,-12)
                    Image(.grass)
                        .padding(.bottom,-40)
                        .zIndex(1)
                    Image(.river)
                        .padding(.bottom,40)
                }
                
                //Main VStack
                VStack(){
                    //Top Part
                    VStack(alignment:.leading,spacing:12) {
                        HStack {
                            Text(currentFormattedDate)
                                .font(.headingFD3)
                                .foregroundStyle(Color.terniaryFD)
                            Spacer()
                            //Button navigate
                            NavigationLink(destination: MapView().ignoresSafeArea()){
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .resizable()
                                        .frame(width: 10,height: 14)
                                        .foregroundStyle(Color.black)
                                    //Change to current location
                                    Text("Legian")
                                        .font(.headingFD3)
                                        .foregroundStyle(Color.black)
                                    Image(systemName: "greaterthan")
                                        .resizable()
                                        .frame(width: 10,height: 14)
                                        .foregroundStyle(Color.black)
                                    
                                }
                                .padding(8)
                                .background(
                                    Capsule()
                                        .fill(Color.primaryFD.opacity(0.5))
                                        .shadow(radius: 4)
                                )
                            }
                        }
                        HStack(spacing: 15) {
                            //need to change later with data
                            Image(.cloud)
                                .resizable()
                                .frame(width: 54, height: 32)
                            VStack () {
                                Text("19")
                                    .font(.headingFD2)
                                    .foregroundStyle(Color.terniaryFD)
                                Text("Sunny")
                                    .font(.bodyFD2)
                                    .foregroundStyle(Color.terniaryFD)
                            }
                        }
                        
                    }
                    .padding(.horizontal, 40)
                    
                    VStack(spacing:20) {
                        Image(.safeCaution)
                        Image(.mascot)
                    }
                    
                    Spacer()
                    
                    ZStack(alignment:.top) {
                        InformationCard(
                            status: viewModel.status,
                            currentLevel: viewModel.currentLevel,
                            rateValue: viewModel.rateValue,
                            trend: viewModel.trend
                            )
                        TimeCard(
                            status: viewModel.status,
                            timeToBank: viewModel.timeToBank
                        ).padding(.top,10)
                    }
                }.ignoresSafeArea(edges:.bottom)
                
            }
            
        }.task {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}

#Preview {
    DashboardView()
}
