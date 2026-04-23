import SwiftUI

struct CircularTimerView: View {
    let progress: Double
    let timeRemaining: TimeInterval
    let isWarning: Bool

    @State private var pulse: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.surfaceElevated, lineWidth: 18)

            Circle()
                .trim(from: 0, to: 1 - progress)
                .stroke(
                    isWarning ? AnyShapeStyle(Theme.danger) : AnyShapeStyle(Theme.accentGradient),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
                .shadow(color: (isWarning ? Theme.danger : Theme.accent).opacity(0.55), radius: 18)

            VStack(spacing: 8) {
                Text(formatted(timeRemaining))
                    .font(.displayLarge)
                    .foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText())
                Text("REMAINING")
                    .font(.labelStrong)
                    .tracking(4)
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .scaleEffect(pulse ? 1.012 : 1)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private func formatted(_ time: TimeInterval) -> String {
        let total = Int(time.rounded(.up))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
