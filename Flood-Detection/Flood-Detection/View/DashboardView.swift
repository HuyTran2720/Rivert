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
    @AppStorage("appLanguage") private var appLanguage: String = "en"

    // Flip to false to hide the manual status picker and always use live data.
    private let showStatusOverride = false

    @State private var debugStatusOverride: SafetyStatus? = nil

    private var displayStatus: SafetyStatus {
        (showStatusOverride ? debugStatusOverride : nil) ?? viewModel.status
    }

    // Top half's accent color: white for danger since the accent color there is too dark to read against the red gradient.
    private var topAccentColor: Color {
        displayStatus == .danger ? .white : Color.statusAccent(for: displayStatus)
    }

    //Fot Date
    private var currentFormattedDate: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, d MMMM"
            formatter.locale = Locale(identifier: appLanguage == "id" ? "id_ID" : "en_US_POSIX")
            return formatter.string(from: Date())
        }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment:.top) {
                //Background Color
                Rectangle()
                    .fill(LinearGradient.backgroundGradient(for: displayStatus))
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: displayStatus)
                
                //Background Image
                DashboardBackground(status: displayStatus)
                    .padding(.top,130)
                LottieMascot(status: displayStatus)
                
                //Main VStack
                VStack(){
                    if showStatusOverride {
                        Picker("Preview Status", selection: $debugStatusOverride) {
                            Text("Live").tag(SafetyStatus?.none)
                            ForEach(SafetyStatus.allCases, id: \.self) { status in
                                Text(status.rawValue.capitalized).tag(SafetyStatus?.some(status))
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 40)
                    }

                    //Top Part
                    VStack(alignment:.leading,spacing:12) {
                        HStack {
                            Text(currentFormattedDate)
                                .font(.headingFD3)
                                .foregroundStyle(topAccentColor)
                            Spacer()
                            
                            // Language dropdown
                            Menu {
                                Button {
                                    appLanguage = "en"
                                } label: {
                                    HStack {
                                        Text("English")
                                        if appLanguage == "en" { Image(systemName: "checkmark") }
                                    }
                                }
                                Button {
                                    appLanguage = "id"
                                } label: {
                                    HStack {
                                        Text("Indonesia")
                                        if appLanguage == "id" { Image(systemName: "checkmark") }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(appLanguage.uppercased())
                                        .font(.headingFD3)
                                        .foregroundStyle(Color.black)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Color.black)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.primaryFD.opacity(0.5))
                                        .shadow(radius: 4)
                                )
                            }
                            
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
                    }
                    .padding(.horizontal, 40)

                    // Sits OUTSIDE the 40pt inset above: the card is a
                    // fixed 364 wide, which will not fit inside it on a
                    // 402pt screen.
                    WeatherCard(slots: viewModel.weatherSlots)
                        .padding(.top, 12)
                    
                    VStack(spacing:20) {
                        SafetyStatusCard(status: displayStatus, size: .small)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    ZStack(alignment:.top) {
                        InformationCard(
                            status: displayStatus,
                            currentLevel: viewModel.currentLevel,
                            rateValue: viewModel.rateValue,
                            trend: viewModel.trend
                            )
                        TimeCard(
                            status: displayStatus,
                            timeToBank: viewModel.timeToBank
                        ).padding(.top,10)
                    }
                }.ignoresSafeArea(edges:.bottom)
                
            }
            .id(appLanguage)
            
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
