//
//  MainInfoView.swift
//  Flood-Detection
//
//  Created by RyanMFDR on 06/08/26.
//

import SwiftUI
import AVFoundation

struct MainInfoView : View {
    @State private var yOffset: CGFloat = 0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isShaking = false
    
    
    var body: some View {
            VStack(alignment:.leading) {
                //Top part
                HStack {
                    VStack(alignment:.leading) {
                        Text("Thu, 6 August")
                        HStack {
                            Image(systemName: "cloud.rain")
                            Text("60%")
                        }
                    }
                    
                    Spacer()
                    NavigationLink(destination: MapView() .ignoresSafeArea()){
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            Text("Legian")
                                .bold()
                        }
                    }.padding()
                }
                Spacer()
                
                //Current time
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 40) {
                        Text("07.00")
                            .font(.title2).bold()
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1.0 : 0.3)
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                            }
                        
                        Text("08.00")
                            .font(.title2).bold()
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1.0 : 0.3)
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                            }
                    }
                }
                .scrollTargetBehavior(.viewAligned)
                .safeAreaPadding(.horizontal, 180)
                .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                
                VStack(spacing:1) {
                    ZStack {
                        Text("CAUTION!")
                            .font(.system(size:12))
                        Image(systemName: "bubble")
                            .resizable()
                            .frame(width: 90, height: 65)
                    }.padding(.leading,90)
                    //Character
                    HStack {
                        Spacer()
                        Image(.bear)
                            .resizable()
                            .frame(width: 180, height: 300)
                            .offset(y: yOffset)
                            .onTapGesture {
                                guard !isShaking else { return }
                                let duration = playSound()
                                
                                isShaking = true
                                
                                withAnimation(.linear(duration: 0.05).repeatForever(autoreverses: true)) {
                                    yOffset = -10
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        yOffset = 0
                                        isShaking = false
                                    }
                                }
                            }
                        Spacer()
                    }
                }
                Spacer()
                //Bottom part
                VStack (alignment:.leading){
                    Text("Rate of water rise")
                    VStack(alignment:.leading){
                        Text("5cm/min")
                            .font(.bodyFD)
                        Text("↑ postrise")
                    }.padding(.top,10)
                }.padding(.leading,25)
                    .padding(.bottom,15)
                
            }
        }
        
        private func playSound() -> Double {
            guard let url = Bundle.main.url(forResource: "chicken", withExtension: "mp3") else {
                print("Audio file chicken.mp3 not found")
                return 0.5
            }
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                return audioPlayer?.duration ?? 0.5
            } catch {
                print("Error playing audio:\(error.localizedDescription)")
                return 0.5
            }
        }
    }



#Preview {
    MainInfoView()
}
