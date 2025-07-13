import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    
    // Background Colors
    static let pageBackground = Color(.systemBackground)
    static let cardBackground = Color(.secondarySystemBackground)
    static let tabBarBackground = Color(.systemBackground)
    
    // Primary Colors
    static let primaryBlue = Color(hex: 0x007AFF)
    static let primaryGreen = Color(hex: 0x34C759)
    static let primaryOrange = Color(hex: 0xFF9500)
    static let primaryRed = Color(hex: 0xFF3B30)
    
    // Accent Colors
    static let accentBlue = Color(hex: 0x5AC8FA)
    static let accentGreen = Color(hex: 0x30D158)
    static let accentOrange = Color(hex: 0xFF9F0A)
    static let accentPurple = Color(hex: 0xAF52DE)
    
    // Text Colors
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let tertiaryText = Color(.tertiaryLabel)
    
    // Border Colors
    static let borderColor = Color(.separator)
    static let lightBorder = Color(.systemGray5)
    
    // Status Colors
    static let successColor = Color(hex: 0x34C759)
    static let warningColor = Color(hex: 0xFF9500)
    static let errorColor = Color(hex: 0xFF3B30)
    static let infoColor = Color(hex: 0x007AFF)
}
