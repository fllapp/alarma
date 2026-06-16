import SwiftUI

struct AppColors {
    static let background = Color.black
    static let cardBackground = Color(white: 0.12, alpha: 1.0)
    static let accentBlue = Color.blue
    static let accentOrange = Color.orange
    static let accentRed = Color.red
    static let textPrimary = Color.white
    static let textSecondary = Color.gray
}

struct AppFonts {
    static func timeFont(size: CGFloat) -> Font {
        .system(size: size, weight: .light, design: .monospaced)
    }
}
