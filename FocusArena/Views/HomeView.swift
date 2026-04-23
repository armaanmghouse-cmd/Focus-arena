import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var settingsStore: SettingsStore
    @State private var showSetup = false

    var body: some View {
        ZStack {
            Theme.intenseGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header
                    levelCard
                    statsRow
                    quickActions
                    motivationCard
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showSetup) {
            SessionSetupView()
                .presentationDragIndicator(.visible)
                .presentationDetents([.large])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("FOCUS ARENA")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .tracking(6)
                .foregroundStyle(Theme.accent)
            Text("Step into the ring.")
                .font(.titleHero)
                .foregroundStyle(Theme.textPrimary)
            Text("Stay in the app. Beat the timer. Hold your streak.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var levelCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("LEVEL")
                        .font(.labelStrong)
                        .tracking(3)
                        .foregroundStyle(Theme.textMuted)
                    Text("\(profileStore.profile.level)")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(profileStore.profile.totalXP) XP")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.accent)
                    Text("\(profileStore.profile.xpInCurrentLevel) / \(profileStore.profile.xpForNextLevel) to next")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                }
            }

            ProgressView(value: profileStore.profile.levelProgress)
                .progressViewStyle(.linear)
                .tint(Theme.accent)
                .scaleEffect(x: 1, y: 1.6, anchor: .center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Theme.accent.opacity(0.25), lineWidth: 1)
                )
        )
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatChip(label: "Streak", value: "\(profileStore.profile.currentStreak)d",
                     accent: Theme.warning, icon: "flame.fill")
            StatChip(label: "Wins", value: "\(profileStore.profile.totalSuccessfulSessions)",
                     accent: Theme.success, icon: "checkmark.shield.fill")
            StatChip(label: "Fails", value: "\(profileStore.profile.totalFailedSessions)",
                     accent: Theme.danger, icon: "xmark.octagon.fill")
        }
    }

    private var quickActions: some View {
        VStack(spacing: 14) {
            PrimaryButton(title: "ENTER THE ARENA", icon: "bolt.fill") {
                showSetup = true
            }
            HStack(spacing: 12) {
                quickStartButton(label: "Quick 25", minutes: 25)
                quickStartButton(label: "Sprint 10", minutes: 10)
                quickStartButton(label: "Deep 50", minutes: 50)
            }
        }
    }

    private func quickStartButton(label: String, minutes: Int) -> some View {
        Button {
            settingsStore.setDuration(TimeInterval(minutes * 60))
            showSetup = true
        } label: {
            VStack(spacing: 4) {
                Text("\(minutes)m")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.surfaceElevated)
            )
        }
        .buttonStyle(.plain)
    }

    private var motivationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundStyle(settingsStore.settings.strictMode ? Theme.danger : Theme.accent)
                Text(settingsStore.settings.strictMode ? "STRICT MODE ARMED" : "GRACE PERIOD ON")
                    .font(.labelStrong)
                    .tracking(2)
                    .foregroundStyle(Theme.textPrimary)
            }
            Text(settingsStore.settings.strictMode
                 ? "One slip and the session dies. No second chances."
                 : "You have \(Int(settingsStore.settings.gracePeriod))s to return before failure.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.surface)
        )
    }
}
