import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject private var historyStore: HistoryStore
    @EnvironmentObject private var profileStore: ProfileStore

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.intenseGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        focusChartCard
                        winRateCard
                        lifetimeStats
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Stats")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var focusChartCard: some View {
        let totals = historyStore.dailyTotals(lastDays: 7)
        return VStack(alignment: .leading, spacing: 12) {
            Text("FOCUS · LAST 7 DAYS")
                .font(.labelStrong)
                .tracking(3)
                .foregroundStyle(Theme.textMuted)

            Chart(totals) { day in
                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Minutes", day.focusSeconds / 60)
                )
                .foregroundStyle(Theme.accentGradient)
                .cornerRadius(6)
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.08))
                    AxisValueLabel().foregroundStyle(Theme.textMuted)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                        .foregroundStyle(Theme.textMuted)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Theme.surface)
        )
    }

    private var winRateCard: some View {
        let total = profileStore.profile.totalSuccessfulSessions + profileStore.profile.totalFailedSessions
        let rate = total == 0 ? 0 : Double(profileStore.profile.totalSuccessfulSessions) / Double(total)
        return VStack(alignment: .leading, spacing: 12) {
            Text("WIN RATE")
                .font(.labelStrong)
                .tracking(3)
                .foregroundStyle(Theme.textMuted)
            HStack(alignment: .firstTextBaseline) {
                Text("\(Int((rate * 100).rounded()))%")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.success)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(profileStore.profile.totalSuccessfulSessions) wins")
                        .foregroundStyle(Theme.success)
                    Text("\(profileStore.profile.totalFailedSessions) losses")
                        .foregroundStyle(Theme.danger)
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            ProgressView(value: rate)
                .tint(Theme.success)
                .scaleEffect(x: 1, y: 1.4)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Theme.surface)
        )
    }

    private var lifetimeStats: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatChip(label: "Total Focus",
                         value: formatHours(profileStore.profile.totalFocusTime),
                         accent: Theme.accent, icon: "clock.fill")
                StatChip(label: "Longest Streak",
                         value: "\(profileStore.profile.longestStreak)d",
                         accent: Theme.warning, icon: "flame.fill")
            }
            HStack(spacing: 12) {
                StatChip(label: "Level",
                         value: "\(profileStore.profile.level)",
                         accent: Theme.accentSecondary, icon: "star.fill")
                StatChip(label: "Total XP",
                         value: "\(profileStore.profile.totalXP)",
                         accent: Theme.accent, icon: "bolt.fill")
            }
        }
    }

    private func formatHours(_ seconds: TimeInterval) -> String {
        let hours = seconds / 3600
        if hours >= 1 { return String(format: "%.1fh", hours) }
        return "\(Int(seconds / 60))m"
    }
}
