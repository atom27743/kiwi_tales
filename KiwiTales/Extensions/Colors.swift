//
//  ColorTheme.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//

import SwiftUI

extension Color {
    // Create new object with hex string
    init?(hex: String, opacity: Double = 1.0) {
        // Delete "#" prefix
        let hexNorm = hex.hasPrefix("#") ? String(hex.dropFirst(1)) : hex

        // Scan each byte of RGB respectively
        let scanner = Scanner(string: hexNorm)
        var color: UInt64 = 0
        
        if scanner.scanHexInt64(&color) {
            let red = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(color & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue, opacity: opacity)
        } else {
            // Invalid format
            return nil
        }
    }
    
    static let theme = ColorTheme()
}

extension UIColor {
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

struct ColorTheme {
    let accent: Color
    let background: Color
    let primary: Color
    let secondary: Color
    let text: Color
    
    init(
        accent: Color = Color.accentColor,
        background: Color = Color("appBackground"),
        primary: Color = Color("appPrimary"),
        secondary: Color = Color("appSecondary"),
        text: Color = Color("appText")
    ) {
        self.accent = accent
        self.background = background
        self.primary = primary
        self.secondary = secondary
        self.text = text
    }
}
