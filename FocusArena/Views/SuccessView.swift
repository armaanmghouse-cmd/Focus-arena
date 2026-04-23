import SwiftUI

struct SuccessView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @EnvironmentObject private var profileStore: ProfileStore

    let session: FocusSession
    @State private var animateBadge = false

    var body: some View {
        ZStack {
            Theme.successGradient.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(Theme.success.opacity(0.4), lineWidth: 3)
                        .frame(width: 200, height: 200)
                        .scaleEffect(animateBadge ? 1.4 : 1)
                        .opacity(animateBadge ? 0 : 1)
                    Circle()
                        .fill(Theme.success.opacity(0.15))
                        .frame(width: 160, height: 160)
                    Image(systemName: "checkmark")
                        .font(.system(size: 90, weight: .black))
                        .foregroundStyle(Theme.success)
                        .shadow(color: Theme.success, radius: 20)
                }

                VStack(spacing: 10) {
                    Text("VICTORY")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .tracking(8)
                        .foregroundStyle(Theme.success)
                    Text(session.task)
                        .font(.titleHero)
                        .foregroundStyle(Theme.textPrimary)
                    Text("You held the line for \(formatMinutes(session.actualDuration)).")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                rewardCard

                Spacer()

                PrimaryButton(title: "RETURN TO HOME", icon: "arrow.right") {
                    sessionManager.dismissResultScreen()
                }
            }
            .padding(28)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                animateBadge = true
            }
        }
    }

    private var rewardCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                rewardItem(label: "XP Earned", value: "+\(session.xpEarned)", color: Theme.accent)
                rewardItem(label: "Streak", value: "\(profileStore.profile.currentStreak)d", color: Theme.warning)
            }
            HStack(spacing: 12) {
                rewardItem(label: "Level", value: "\(profileStore.profile.level)", color: Theme.accentSecondary)
                rewardItem(label: "Total Wins", value: "\(profileStore.profile.totalSuccessfulSessions)", color: Theme.success)
            }
        }
    }

    private func rewardItem(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 26, weight: .heavy, design: .rounded))
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

    private func formatMinutes(_ seconds: TimeInterval) -> String {
        let minutes = Int((seconds / 60).rounded())
        return "\(minutes) min"
    }
}
