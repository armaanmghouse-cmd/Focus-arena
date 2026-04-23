import SwiftUI

enum Theme {
    // MARK: - Colors

    enum Palette {
        static let accent = Color(hex: 0xE11D2A)
        static let accentPressed = Color(hex: 0xB8161F)
        static let accentSoft = Color(hex: 0xFBE4E5)

        static let ink = Color(hex: 0x0A0A0A)
        static let inkSecondary = Color(hex: 0x4A4A4A)
        static let inkTertiary = Color(hex: 0x8A8A8A)

        static let paper = Color(hex: 0xFFFFFF)
        static let surface = Color(hex: 0xF6F6F6)
        static let surfaceElevated = Color(hex: 0xFAFAFA)
        static let border = Color(hex: 0xE6E6E6)
        static let borderStrong = Color(hex: 0xCFCFCF)

        static let success = Color(hex: 0x16663A)
        static let warning = Color(hex: 0xB45309)
    }

    // MARK: - Typography

    enum Font {
        static func display(_ size: CGFloat = 34) -> SwiftUI.Font {
            .system(size: size, weight: .black, design: .default)
        }
        static func headline(_ size: CGFloat = 22) -> SwiftUI.Font {
            .system(size: size, weight: .bold, design: .default)
        }
        static func title(_ size: CGFloat = 17) -> SwiftUI.Font {
            .system(size: size, weight: .semibold, design: .default)
        }
        static func body(_ size: CGFloat = 15) -> SwiftUI.Font {
            .system(size: size, weight: .regular, design: .default)
        }
        static func caption(_ size: CGFloat = 12) -> SwiftUI.Font {
            .system(size: size, weight: .medium, design: .default)
        }
        static func mono(_ size: CGFloat = 13) -> SwiftUI.Font {
            .system(size: size, weight: .semibold, design: .monospaced)
        }
    }

    // MARK: - Metrics

    enum Metrics {
        static let cornerRadius: CGFloat = 16
        static let cornerRadiusSmall: CGFloat = 10
        static let spacing: CGFloat = 16
        static let spacingSmall: CGFloat = 8
        static let spacingLarge: CGFloat = 24
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Helpers

struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    var elevated: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius, style: .continuous)
                    .fill(Theme.Palette.paper)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius, style: .continuous)
                    .stroke(Theme.Palette.border, lineWidth: 1)
            )
            .shadow(color: elevated ? .black.opacity(0.06) : .clear, radius: 12, x: 0, y: 4)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16, elevated: Bool = false) -> some View {
        modifier(CardStyle(padding: padding, elevated: elevated))
    }
}

struct RedPill: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .black))
            .tracking(1.1)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Theme.Palette.accent)
            .clipShape(Capsule())
    }
}

struct InkPill: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .black))
            .tracking(1.1)
            .foregroundColor(Theme.Palette.paper)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Theme.Palette.ink)
            .clipShape(Capsule())
    }
}
