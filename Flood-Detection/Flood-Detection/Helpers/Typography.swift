//
//  Typography.swift
//  Flood-Detection
//
//  Created by RyanMFDR on 11/08/26.
//

import SwiftUI

//Change this to the actual design system later yepp hehe

//MARK: - Fonts
extension Font {
    static var headingFD1: Font { .custom("Avenir-Black", size: 32)}
    static var headingFD2: Font { .custom("Avenir-Black", size: 16)}
    static var headingFD3: Font { .custom("Avenir-Black", size: 14)}
    static var bodyFD1: Font { .custom("Avenir-Black", size: 14)}
    static var bodyFD2: Font { .custom("Avenir-Black", size: 12)}
    static var bodyFD3: Font { .custom("Avenir-Black", size: 10)}
}

//MARK: - Color
extension Color {
    
    //Primary, secondary, terniary
    static let primaryFD = Color.white
    static let secondaryFD = Color(red: 77 / 255.0, green: 161 / 255.0, blue: 171 / 255.0)
    static let terniaryFD = Color(red: 62 / 255.0, green: 124 / 255.0, blue: 144 / 255.0)

    
    //dashboard background color
    static let softCyan = Color(red: 196 / 255.0, green: 237 / 255.0, blue: 238 / 255.0)
    static let softMint = Color(red: 239 / 255.0, green: 246 / 255.0, blue: 234 / 255.0)
    
    //warning color - yellow
    static let yellowOutline = Color(red: 255 / 255.0, green: 236 / 255.0, blue: 126 / 255.0)
    static let yellowTitle   = Color(red: 201 / 255.0, green: 151 / 255.0, blue: 0 / 255.0)
    static let yellowText    = Color(red: 159 / 255.0, green: 119 / 255.0, blue: 0 / 255.0)

    //warning color - red
    static let redOutline    = Color(red: 255 / 255.0, green: 151 / 255.0, blue: 151 / 255.0)
    static let redTitle      = Color(red: 214 / 255.0, green: 62 / 255.0, blue: 62 / 255.0)
    static let redText       = Color(red: 215 / 255.0, green: 154 / 255.0, blue: 154 / 255.0)
    
}

//for Dashboard background
extension LinearGradient {
    static let backgroundGradient = LinearGradient(
        colors: [.softCyan, .softMint],
        startPoint: .top,
        endPoint: .bottom
    )
}


struct ColorView : View {
    var body: some View {
        ZStack {
            Rectangle().fill(
                LinearGradient.backgroundGradient
            )
            VStack {
                Text("Primary")
                    .foregroundStyle(Color.white)
                Text("Seconadary")
                    .foregroundStyle(Color.secondaryFD)
                Text("Terniary")
                    .foregroundStyle(Color.terniaryFD)
            }
        }
    }
}

#Preview {
    ColorView()
}
