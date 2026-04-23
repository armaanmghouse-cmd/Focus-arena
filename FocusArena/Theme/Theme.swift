import SwiftUI

enum Theme {
    static let background = Color(red: 0.04, green: 0.05, blue: 0.08)
    static let surface = Color(red: 0.08, green: 0.10, blue: 0.14)
    static let surfaceElevated = Color(red: 0.12, green: 0.14, blue: 0.19)
    static let accent = Color(red: 0.36, green: 0.85, blue: 1.00)
    static let accentSecondary = Color(red: 0.62, green: 0.45, blue: 1.00)
    static let success = Color(red: 0.30, green: 0.95, blue: 0.55)
    static let danger = Color(red: 1.00, green: 0.30, blue: 0.40)
    static let warning = Color(red: 1.00, green: 0.78, blue: 0.30)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.65)
    static let textMuted = Color.white.opacity(0.40)

    static let intenseGradient = LinearGradient(
        colors: [Color(red: 0.05, green: 0.07, blue: 0.16),
                 Color(red: 0.02, green: 0.03, blue: 0.07)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let accentGradient = LinearGradient(
        colors: [accent, accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let dangerGradient = LinearGradient(
        colors: [Color(red: 0.55, green: 0.05, blue: 0.10),
                 Color(red: 0.20, green: 0.02, blue: 0.05)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let successGradient = LinearGradient(
        colors: [Color(red: 0.05, green: 0.40, blue: 0.20),
                 Color(red: 0.02, green: 0.15, blue: 0.08)],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Font {
    static let display = Font.system(size: 80, weight: .heavy, design: .rounded).monospacedDigit()
    static let displayLarge = Font.system(size: 110, weight: .black, design: .rounded).monospacedDigit()
    static let titleHero = Font.system(size: 32, weight: .black, design: .rounded)
    static let titleSection = Font.system(size: 22, weight: .bold, design: .rounded)
    static let labelStrong = Font.system(size: 14, weight: .semibold, design: .rounded)
    static let mono = Font.system(.body, design: .monospaced)
}
