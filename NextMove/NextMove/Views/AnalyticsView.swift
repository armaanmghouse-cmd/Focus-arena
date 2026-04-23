import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var appState: AppState

    private var recentLogs: [DayLog] {
        appState.dayLogStore.recentLogs(limit: 14).reversed()
    }

    private var patterns: [RegretPattern] {
        AnalyticsService.patterns(from: appState.dayLogStore.allReflections())
    }

    private var streak: Int {
        var count = 0
        let sorted = appState.dayLogStore.recentLogs(limit: 30)
        for log in sorted {
            if log.completionRatio > 0 {
                count += 1
            } else {
                break
            }
        }
        return count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    topStatsCard
                    scoreTrendCard
                    regretPatternsCard
                    categoryBreakdownCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Insights")
        }
    }

    private var topStatsCard: some View {
        HStack(spacing: 12) {
            statTile(
                label: "Streak",
                value: "\(streak)",
                suffix: streak == 1 ? "day" : "days",
                color: Theme.accent,
                symbol: "flame.fill"
            )
            statTile(
                label: "Avg score",
                value: avgScoreText,
                suffix: nil,
                color: Theme.success,
                symbol: "chart.line.uptrend.xyaxis"
            )
        }
    }

    private var avgScoreText: String {
        let scores = recentLogs.map(\.score).filter { $0 > 0 }
        guard !scores.isEmpty else { return "—" }
        let avg = scores.reduce(0, +) / Double(scores.count)
        return "\(Int(avg))"
    }

    private func statTile(label: String, value: String, suffix: String?, color: Color, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: symbol)
                    .foregroundStyle(color)
                Text(label.uppercased())
                    .font(.nmLabel)
                    .foregroundStyle(Theme.textSecondary)
                    .kerning(1.1)
                Spacer()
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 36, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(Theme.textPrimary)
                if let suffix {
                    Text(suffix)
                        .font(.nmCaption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18).fill(Theme.surface)
        )
    }

    @ViewBuilder
    private var scoreTrendCard: some View {
        SectionCard(title: "Score trend", subtitle: "Last 14 days") {
            if recentLogs.filter({ $0.score > 0 }).isEmpty {
                Text("Complete goals for a few days to build a trend.")
                    .font(.nmBody)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                Chart {
                    ForEach(recentLogs) { log in
                        LineMark(
                            x: .value("Date", log.date),
                            y: .value("Score", log.score)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Theme.accentGradient)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))

                        AreaMark(
                            x: .value("Date", log.date),
                            y: .value("Score", log.score)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.accent.opacity(0.3), Theme.accent.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        PointMark(
                            x: .value("Date", log.date),
                            y: .value("Score", log.score)
                        )
                        .foregroundStyle(Theme.accent)
                        .symbolSize(50)
                    }
                }
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 50, 100])
                }
                .frame(height: 180)
            }
        }
    }

    @ViewBuilder
    private var regretPatternsCard: some View {
        SectionCard(
            title: "Regret patterns",
            subtitle: "What you keep wishing you'd done"
        ) {
            if patterns.isEmpty {
                Text("Reflect at night for a few days to surface patterns.")
                    .font(.nmBody)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(patterns) { pattern in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("You frequently regret not \(pattern.tag)")
                                    .font(.nmBody.weight(.semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Text("\u{00D7}\(pattern.count)")
                                    .font(.nmLabel)
                                    .foregroundStyle(Theme.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Theme.accent.opacity(0.12)))
                            }
                            Text(pattern.suggestion)
                                .font(.nmCaption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12).fill(Theme.surfaceElevated)
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var categoryBreakdownCard: some View {
        let breakdown = categoryBreakdown()
        if !breakdown.isEmpty {
            SectionCard(title: "Category balance", subtitle: "Completed goals this period") {
                Chart {
                    ForEach(breakdown, id: \.category) { item in
                        BarMark(
                            x: .value("Count", item.count),
                            y: .value("Category", item.category.label)
                        )
                        .foregroundStyle(item.category.color)
                        .cornerRadius(6)
                    }
                }
                .frame(height: CGFloat(breakdown.count) * 36 + 20)
            }
        }
    }

    private struct CategoryCount {
        let category: GoalCategory
        let count: Int
    }

    private func categoryBreakdown() -> [CategoryCount] {
        var counts: [GoalCategory: Int] = [:]
        for log in recentLogs {
            for goal in log.goals where goal.isCompleted {
                counts[goal.category, default: 0] += 1
            }
        }
        return counts
            .map { CategoryCount(category: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
}
