import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var historyStore: HistoryStore

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.intenseGradient.ignoresSafeArea()

                if historyStore.sessions.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            todaySummary
                            ForEach(historyStore.sessions) { session in
                                SessionRow(session: session)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("History")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "list.bullet.rectangle.portrait")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(Theme.textMuted)
            Text("No sessions yet")
                .font(.titleSection)
                .foregroundStyle(Theme.textPrimary)
            Text("Step into the arena to start your record.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var todaySummary: some View {
        let today = Date()
        let count = historyStore.successCount(on: today)
        let totalSeconds = historyStore.focusTime(on: today)
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("TODAY")
                    .font(.labelStrong)
                    .tracking(3)
                    .foregroundStyle(Theme.textMuted)
                Text("\(count) wins · \(formatMinutes(totalSeconds))")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
            Image(systemName: "flame.fill")
                .font(.system(size: 28))
                .foregroundStyle(Theme.warning)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.surface)
        )
    }

    private func formatMinutes(_ seconds: TimeInterval) -> String {
        let total = Int(seconds / 60)
        return "\(total) min"
    }
}

private struct SessionRow: View {
    let session: FocusSession

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(badgeColor)
                .frame(width: 10, height: 10)
                .shadow(color: badgeColor.opacity(0.5), radius: 4)
            VStack(alignment: .leading, spacing: 4) {
                Text(session.task)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                HStack(spacing: 8) {
                    Text(session.startedAt, style: .date)
                    Text("·")
                    Text(session.startedAt, style: .time)
                    if session.strictMode {
                        Text("· STRICT")
                            .foregroundStyle(Theme.danger)
                    }
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textMuted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(durationText)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Text(outcomeLabel)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1)
                    .foregroundStyle(badgeColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.surface)
        )
    }

    private var badgeColor: Color {
        switch session.outcome {
        case .success: return Theme.success
        case .failed: return Theme.danger
        case .inProgress: return Theme.warning
        }
    }

    private var outcomeLabel: String {
        switch session.outcome {
        case .success: return "WIN +\(session.xpEarned)XP"
        case .failed: return session.failureReason?.rawValue.uppercased() ?? "FAILED"
        case .inProgress: return "RUNNING"
        }
    }

    private var durationText: String {
        let total = Int(session.actualDuration.rounded())
        let planned = Int(session.plannedDuration.rounded())
        let m = total / 60
        let pm = planned / 60
        return "\(m)/\(pm)m"
    }
}
