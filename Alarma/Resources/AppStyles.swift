import SwiftUI

struct AppColors {
    static let background = Color.black
    static let cardBackground = Color(white: 0.12)
    static let accentBlue = Color.blue
    static let accentOrange = Color.orange
    static let accentRed = Color.red
    static let textPrimary = Color.white
    static let textSecondary = Color.gray
}

struct AppFonts {
    static func timeFont(size: Double) -> Font {
        .system(size: size, weight: .light, design: .monospaced)
    }
}
