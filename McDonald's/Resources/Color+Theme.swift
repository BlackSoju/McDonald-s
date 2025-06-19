//
//  Color+Theme.swift
//  McDonald's
//
//  Created by 윤준성 on 6/17/25.
//

import SwiftUI

extension Color {
    static let workStartColor = Color(hex: "#D2E6F8")
    static let workEndColor = Color(hex: "#D3F4E7")
    static let hourPickerBG = Color(hex: "#E9F2FA")
    static let minutePickerBG = Color(hex: "#E6F7F0")
    static let hourHighlight = Color(hex: "#B5D9F2")
    static let minuteHighlight = Color(hex: "#B3E6D6")
    static let saveButtonColor = Color(hex: "#60C4AC")
    static let textPrimaryColor = Color(hex: "#6E6E6E")
    static let backgroundColor = Color(hex: "#F5F5F5")
    static let beigeBackground = Color(hex: "#FFFEF9")
    static let pickerShadow = Color.black.opacity(0.05)
    static let embossHighlight = Color.white.opacity(0.6)
    static let embossShadow = Color.black.opacity(0.1)

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
}
