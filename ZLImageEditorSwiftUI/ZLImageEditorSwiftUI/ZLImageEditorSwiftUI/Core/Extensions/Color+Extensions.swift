//
//  Color+Extensions.swift
//  ZLImageEditorSwiftUI
//
//  Created by SwiftUI Rewrite
//

import SwiftUI

public extension Color {
    /// Create color from RGB values (0-255)
    init(red: Int, green: Int, blue: Int, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0,
            opacity: opacity
        )
    }

    /// Create color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Convert to UIColor
    func toUIColor() -> UIColor {
        UIColor(self)
    }
}

// MARK: - Predefined Colors (matching original ZLImageEditor)

public extension Color {
    static let editorRed = Color(red: 249, green: 80, blue: 81)
    static let editorOrange = Color(red: 248, green: 156, blue: 59)
    static let editorYellow = Color(red: 255, green: 195, blue: 0)
    static let editorLightGreen = Color(red: 145, green: 211, blue: 0)
    static let editorGreen = Color(red: 0, green: 193, blue: 94)
    static let editorLightBlue = Color(red: 16, green: 173, blue: 254)
    static let editorBlue = Color(red: 16, green: 132, blue: 236)
    static let editorPurple = Color(red: 99, green: 103, blue: 240)
    static let editorGray = Color(red: 127, green: 127, blue: 127)
}
