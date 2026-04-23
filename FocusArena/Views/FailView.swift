import SwiftUI

struct FailView: View {
    @EnvironmentObject private var sessionManager: SessionManager

    let session: FocusSession
    @State private var shake: CGFloat = 0

    var body: some View {
        ZStack {
            Theme.dangerGradient.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(Theme.danger.opacity(0.3), lineWidth: 3)
                        .frame(width: 200, height: 200)
                    Circle()
                        .fill(Theme.danger.opacity(0.15))
                        .frame(width: 160, height: 160)
                    Image(systemName: "xmark")
                        .font(.system(size: 90, weight: .black))
                        .foregroundStyle(Theme.danger)
                        .shadow(color: Theme.danger, radius: 20)
                }
                .offset(x: shake)

                VStack(spacing: 10) {
                    Text("DEFEATED")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .tracking(8)
                        .foregroundStyle(Theme.danger)
                    Text(session.task)
                        .font(.titleHero)
                        .foregroundStyle(Theme.textPrimary)
                    Text(session.failureReason?.rawValue ?? "Session lost")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                statsCard

                Spacer()

                VStack(spacing: 12) {
                    PrimaryButton(title: "TRY AGAIN", icon: "arrow.clockwise", style: .danger) {
                        sessionManager.dismissResultScreen()
                    }
                    Button {
                        sessionManager.dismissResultScreen()
                    } label: {
                        Text("Back to Home")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textMuted)
                    }
                }
            }
            .padding(28)
        }
        .onAppear {
            withAnimation(.linear(duration: 0.06).repeatCount(6, autoreverses: true)) {
                shake = 12
            }
            withAnimation(.linear(duration: 0.06).delay(0.36)) {
                shake = 0
            }
        }
    }

    private var statsCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                rewardItem(label: "Time Held", value: format(session.actualDuration), color: Theme.warning)
                rewardItem(label: "Time Lost", value: format(session.plannedDuration - session.actualDuration), color: Theme.danger)
            }
            HStack(spacing: 12) {
                rewardItem(label: "XP Penalty", value: "-20", color: Theme.danger)
                rewardItem(label: "Streak", value: "RESET", color: Theme.danger)
            }
        }
    }

    private func rewardItem(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(color)
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func format(_ seconds: TimeInterval) -> String {
        let total = Int(seconds.rounded())
        let m = total / 60
        let s = total % 60
        if m > 0 { return "\(m)m \(s)s" }
        return "\(s)s"
    }
}
