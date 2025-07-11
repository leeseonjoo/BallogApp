import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    // The default background color used across the application
    // was previously a light beige tone. To comply with the request
    // to make all pages use a white background, update the constant
    // to plain `.white`.
    static let pageBackground = Color.white
}
