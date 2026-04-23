import SwiftUI

enum Theme {
    // Surfaces — calm, light-first
    static let background = Color(.systemGroupedBackground)
    static let surface = Color(.secondarySystemGroupedBackground)
    static let surfaceElevated = Color(.tertiarySystemGroupedBackground)
    static let divider = Color(.separator)

    // Text
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textMuted = Color(.tertiaryLabel)

    // Brand
    static let accent = Color(red: 0.384, green: 0.502, blue: 0.961)
    static let accentSecondary = Color(red: 0.482, green: 0.38, blue: 0.95)
    static let nightAccent = Color(red: 0.35, green: 0.40, blue: 0.75)

    // States
    static let success = Color(red: 0.30, green: 0.75, blue: 0.45)
    static let warning = Color(red: 0.98, green: 0.72, blue: 0.30)
    static let danger = Color(red: 0.95, green: 0.35, blue: 0.40)

    // Priority colors
    static let priorityLow = Color(red: 0.45, green: 0.70, blue: 0.60)
    static let priorityMedium = Color(red: 0.38, green: 0.58, blue: 0.95)
    static let priorityHigh = Color(red: 0.96, green: 0.60, blue: 0.28)
    static let priorityCritical = Color(red: 0.95, green: 0.35, blue: 0.40)

    // Category colors
    static let catSchool = Color(red: 0.38, green: 0.58, blue: 0.95)
    static let catSports = Color(red: 0.96, green: 0.55, blue: 0.28)
    static let catPersonal = Color(red: 0.82, green: 0.40, blue: 0.65)
    static let catWork = Color(red: 0.35, green: 0.55, blue: 0.60)
    static let catHealth = Color(red: 0.30, green: 0.75, blue: 0.45)
    static let catOther = Color(red: 0.55, green: 0.55, blue: 0.62)

    // Gradients
    static let accentGradient = LinearGradient(
        colors: [accent, accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let nightGradient = LinearGradient(
        colors: [
            Color(red: 0.11, green: 0.14, blue: 0.28),
            Color(red: 0.05, green: 0.06, blue: 0.15)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let dawnGradient = LinearGradient(
        colors: [
            Color(red: 0.98, green: 0.92, blue: 0.88),
            Color(red: 0.93, green: 0.90, blue: 0.98)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Font {
    static let nmDisplay = Font.system(size: 56, weight: .bold, design: .rounded).monospacedDigit()
    static let nmScore = Font.system(size: 72, weight: .heavy, design: .rounded).monospacedDigit()
    static let nmTitleHero = Font.system(size: 30, weight: .bold, design: .rounded)
    static let nmTitleSection = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let nmBody = Font.system(.body, design: .rounded)
    static let nmLabel = Font.system(size: 13, weight: .semibold, design: .rounded)
    static let nmCaption = Font.system(size: 12, weight: .medium, design: .rounded)
}
