import SwiftUI

struct PrimaryButton: View {
    enum Style { case filled, outline, ghost }

    let title: String
    var icon: String? = nil
    var style: Style = .filled
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(foreground)
                        .scaleEffect(0.9)
                } else if let icon {
                    Image(systemName: icon).font(.system(size: 15, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundColor(foreground)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(border, lineWidth: style == .outline ? 1.5 : 0)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(isEnabled ? 1.0 : 0.4)
        }
        .disabled(!isEnabled || isLoading)
        .buttonStyle(PressableButtonStyle())
    }

    private var foreground: Color {
        switch style {
        case .filled: return .white
        case .outline: return Theme.Palette.ink
        case .ghost: return Theme.Palette.ink
        }
    }

    private var background: Color {
        switch style {
        case .filled: return Theme.Palette.ink
        case .outline: return Theme.Palette.paper
        case .ghost: return .clear
        }
    }

    private var border: Color {
        style == .outline ? Theme.Palette.ink : .clear
    }
}

struct AccentButton: View {
    let title: String
    var icon: String? = nil
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 15, weight: .bold))
                }
                Text(title).font(.system(size: 16, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundColor(.white)
            .background(Theme.Palette.accent)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(isEnabled ? 1.0 : 0.4)
        }
        .disabled(!isEnabled)
        .buttonStyle(PressableButtonStyle())
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: configuration.isPressed)
    }
}
