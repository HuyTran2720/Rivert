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
    static var headingFD1: Font { .system(size: 32, weight: .bold, design: .default) }
    static var headingFD2: Font { .system(size: 16, weight: .bold, design: .default) }
    static var headingFD3: Font { .system(size: 14, weight: .bold, design: .default) }
        
    static var bodyFD1: Font { .system(size: 14, weight: .regular, design: .default) }
    static var bodyFD2: Font { .system(size: 12, weight: .regular, design: .default) }
    static var bodyFD3: Font { .system(size: 10, weight: .regular, design: .default) }
    static var extraFD: Font { .system(size: 8, weight: .regular, design: .default) }
    }


//MARK: - Color
extension Color {
    
    //Primary, secondary, terniary
    static let primaryFD = Color.white
    static let secondaryFD = Color(red: 77 / 255.0, green: 161 / 255.0, blue: 171 / 255.0)
    static let terniaryFD = Color(red: 75 / 255.0, green: 124 / 255.0, blue: 144 / 255.0)
    
    
    //dashboard background color - safe
    static let softCyan = Color(red: 196 / 255.0, green: 237 / 255.0, blue: 238 / 255.0)
    static let softMint = Color(red: 239 / 255.0, green: 246 / 255.0, blue: 234 / 255.0)

    //dashboard background color - caution
    static let softYellow = Color(red: 255 / 255.0, green: 202 / 255.0, blue: 82 / 255.0)  // #FFCA52
    static let softCream  = Color(red: 239 / 255.0, green: 228 / 255.0, blue: 200 / 255.0) // #EFE4C8

    //dashboard background color - danger
    static let softRose  = Color(red: 255 / 255.0, green: 80 / 255.0, blue: 80 / 255.0)    // #FF5050
    static let softBlush = Color(red: 141 / 255.0, green: 141 / 255.0, blue: 141 / 255.0)  // #8D8D8D
    static let extraFD = Color(red: 62 / 255.0, green: 107 / 255.0, blue: 115 / 255.0)
    static let littledotsFD = Color(red: 105 / 255.0, green: 234 / 255.0, blue: 240 / 255.0)
    
    //warning color - yellow
    static let yellowOutline = Color(red: 255 / 255.0, green: 236 / 255.0, blue: 126 / 255.0)
    static let yellowTitle   = Color(red: 201 / 255.0, green: 151 / 255.0, blue: 0 / 255.0)
    static let yellowText    = Color(red: 159 / 255.0, green: 119 / 255.0, blue: 0 / 255.0)
    static let yellowBackground    = Color(red: 255 / 255.0, green: 247 / 255.0, blue: 200 / 255.0)


    //warning color - red
    static let redOutline    = Color(red: 255 / 255.0, green: 151 / 255.0, blue: 151 / 255.0)
    static let redTitle      = Color(red: 214 / 255.0, green: 62 / 255.0, blue: 62 / 255.0)
    static let redText       = Color(red: 164 / 255.0, green: 50 / 255.0, blue: 50 / 255.0) // #A43232
    static let redBackground = Color(red: 255 / 255.0, green: 231 / 255.0, blue: 231 / 255.0)
    
    //warning color - green
    static let greenOutline    = Color(red: 93 / 255.0, green: 232 / 255.0, blue: 111 / 255.0)
    static let greenTitle      = Color(red: 49 / 255.0, green: 158 / 255.0, blue: 73 / 255.0)
    static let greenText       = Color(red: 16 / 255.0, green: 185 / 255.0, blue: 129 / 255.0)
    static let greenBackground = Color(red: 210 / 255.0, green: 255 / 255.0, blue: 222 / 255.0)

    
}

//for Dashboard background
extension LinearGradient {
    static func backgroundGradient(for status: SafetyStatus) -> LinearGradient {
        let colors: [Color]
        switch status {
        case .safe:    colors = [.softCyan, .softMint]
        case .caution: colors = [.softYellow, .softCream]
        case .danger:  colors = [.softRose, .softBlush]
        }
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
}


struct ColorView : View {
    var body: some View {
        ZStack {
            Rectangle().fill(
                LinearGradient.backgroundGradient(for: .safe)
            )
            VStack {
                Text("Primary")
                    .foregroundStyle(Color.white)
                Text("Seconadary")
                    .foregroundStyle(Color.secondaryFD)
                Text("Terniary")
                    .foregroundStyle(Color.terniaryFD)
                Text("Extra")
                    .foregroundStyle(Color.terniaryFD)

            }
        }
    }
}

#Preview {
    ColorView()
}
