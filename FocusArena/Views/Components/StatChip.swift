import SwiftUI

struct StatChip: View {
    let label: String
    let value: String
    var accent: Color = Theme.accent
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon).foregroundStyle(accent)
                }
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(Theme.textMuted)
            }
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(accent.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var style: Style = .accent
    let action: () -> Void

    enum Style { case accent, danger, ghost }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon { Image(systemName: icon) }
                Text(title)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .tracking(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(border, lineWidth: 1)
            )
            .shadow(color: shadow, radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var background: some View {
        switch style {
        case .accent: Theme.accentGradient
        case .danger: Theme.danger
        case .ghost: Theme.surfaceElevated
        }
    }

    private var foreground: Color {
        switch style {
        case .accent: return .black
        case .danger: return .white
        case .ghost: return Theme.textPrimary
        }
    }

    private var border: Color {
        switch style {
        case .accent: return Color.white.opacity(0.15)
        case .danger: return Theme.danger.opacity(0.6)
        case .ghost: return Color.white.opacity(0.08)
        }
    }

    private var shadow: Color {
        switch style {
        case .accent: return Theme.accent.opacity(0.45)
        case .danger: return Theme.danger.opacity(0.45)
        case .ghost: return .clear
        }
    }
}
