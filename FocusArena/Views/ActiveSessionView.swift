import SwiftUI

struct ActiveSessionView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @EnvironmentObject private var settingsStore: SettingsStore
    @State private var showSurrenderConfirm = false
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 32) {
                topBar
                Spacer(minLength: 0)
                CircularTimerView(
                    progress: sessionManager.progress,
                    timeRemaining: sessionManager.timeRemaining,
                    isWarning: isWarning
                )
                .frame(width: 300, height: 300)

                statusCard

                Spacer(minLength: 0)
                surrenderButton
            }
            .padding(28)
        }
        .alert("Surrender?", isPresented: $showSurrenderConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Quit Session", role: .destructive) {
                sessionManager.surrender()
            }
        } message: {
            Text("This counts as a failure. Your streak will reset.")
        }
        .statusBarHidden()
        .onAppear {
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }

    private var isWarning: Bool {
        if case .warning = sessionManager.phase { return true }
        return false
    }

    private var graceRemaining: TimeInterval? {
        if case let .warning(remaining) = sessionManager.phase { return remaining }
        return nil
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        ZStack {
            (isWarning ? Theme.dangerGradient : Theme.intenseGradient)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: isWarning)

            GeometryReader { geo in
                Circle()
                    .stroke(Theme.accent.opacity(0.05), lineWidth: 2)
                    .frame(width: geo.size.width * 1.5, height: geo.size.width * 1.5)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .rotationEffect(.degrees(rotation))

                Circle()
                    .stroke(Theme.accentSecondary.opacity(0.05), lineWidth: 1)
                    .frame(width: geo.size.width * 1.1, height: geo.size.width * 1.1)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .rotationEffect(.degrees(-rotation * 0.6))
            }
            .ignoresSafeArea()
        }
    }

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(sessionManager.activeSession?.task ?? "FOCUS")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Text(sessionManager.activeSession?.strictMode == true ? "STRICT MODE" : "GRACE: \(Int(settingsStore.settings.gracePeriod))s")
                    .font(.labelStrong)
                    .tracking(2)
                    .foregroundStyle(sessionManager.activeSession?.strictMode == true ? Theme.danger : Theme.accent)
            }
            Spacer()
            statusIndicator
        }
    }

    private var statusIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isWarning ? Theme.danger : Theme.success)
                .frame(width: 10, height: 10)
                .shadow(color: isWarning ? Theme.danger : Theme.success, radius: 6)
            Text(isWarning ? "BREACH" : "LOCKED IN")
                .font(.labelStrong)
                .tracking(2)
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(Theme.surface))
    }

    @ViewBuilder
    private var statusCard: some View {
        if let remaining = graceRemaining {
            VStack(spacing: 8) {
                Text("RETURN TO THE ARENA")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(Theme.danger)
                Text(String(format: "%.1fs", remaining))
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.danger)
                    .contentTransition(.numericText())
                Text("Failure imminent.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Theme.danger.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Theme.danger, lineWidth: 1.5)
                    )
            )
            .transition(.scale.combined(with: .opacity))
        } else {
            VStack(spacing: 6) {
                Text("HOLD THE LINE")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(Theme.accent)
                Text("Leaving the app fails the session.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.surface)
            )
        }
    }

    private var surrenderButton: some View {
        Button {
            showSurrenderConfirm = true
        } label: {
            Text("SURRENDER")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .tracking(4)
                .foregroundStyle(Theme.textMuted)
                .padding(.vertical, 14)
                .padding(.horizontal, 28)
                .background(
                    Capsule().stroke(Theme.textMuted.opacity(0.4), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
