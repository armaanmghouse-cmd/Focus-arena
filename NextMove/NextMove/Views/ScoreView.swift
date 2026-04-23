import SwiftUI

struct ScoreView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private var today: DayLog { appState.dayLogStore.today }
    private var yesterday: DayLog? { appState.dayLogStore.yesterday }

    private var score: Double { ScoringService.score(for: today) }
    private var delta: Double {
        ScoringService.improvementDelta(today: today, yesterday: yesterday)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    ZStack {
                        ProgressRing(progress: score / 100, size: 220, gradient: Theme.accentGradient)
                        VStack(spacing: 2) {
                            Text("\(Int(score))")
                                .font(.nmScore)
                                .foregroundStyle(Theme.textPrimary)
                            Text("TODAY'S SCORE")
                                .font(.nmLabel)
                                .foregroundStyle(Theme.textSecondary)
                                .kerning(1.2)
                        }
                    }
                    .padding(.top, 10)

                    if yesterday != nil {
                        Text(ScoringService.improvementText(delta: delta))
                            .font(.nmBody.weight(.semibold))
                            .foregroundStyle(delta >= 0 ? Theme.success : Theme.danger)
                    }

                    SectionCard(title: "Breakdown") {
                        VStack(spacing: 12) {
                            breakdownRow(
                                label: "Goals completed",
                                value: "\(today.completedCount)/\(today.totalCount)"
                            )
                            breakdownRow(
                                label: "Critical-priority done",
                                value: "\(criticalCompleted)/\(criticalTotal)"
                            )
                            breakdownRow(
                                label: "High-priority done",
                                value: "\(highCompleted)/\(highTotal)"
                            )
                        }
                    }

                    if !today.goals.isEmpty {
                        SectionCard(title: "What carried the day") {
                            VStack(spacing: 8) {
                                ForEach(today.goals.filter { $0.isCompleted }) { goal in
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Theme.success)
                                        Text(goal.title)
                                            .font(.nmBody)
                                        Spacer()
                                        PriorityBadge(priority: goal.priority, compact: true)
                                    }
                                }
                                if today.completedCount == 0 {
                                    Text("Nothing completed yet. The day isn't over.")
                                        .font(.nmBody)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }
                        }
                    }

                    if today.goals.contains(where: { !$0.isCompleted }) {
                        SectionCard(title: "What still matters") {
                            VStack(spacing: 8) {
                                ForEach(today.goals.filter { !$0.isCompleted }) { goal in
                                    HStack {
                                        Image(systemName: "circle")
                                            .foregroundStyle(Theme.textMuted)
                                        Text(goal.title)
                                            .font(.nmBody)
                                        Spacer()
                                        PriorityBadge(priority: goal.priority, compact: true)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(18)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .bold()
                }
            }
        }
    }

    private func breakdownRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.nmBody)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .rounded).weight(.semibold).monospacedDigit())
                .foregroundStyle(Theme.textPrimary)
        }
    }

    private var criticalTotal: Int { today.goals.filter { $0.priority == .critical }.count }
    private var criticalCompleted: Int { today.goals.filter { $0.priority == .critical && $0.isCompleted }.count }
    private var highTotal: Int { today.goals.filter { $0.priority == .high }.count }
    private var highCompleted: Int { today.goals.filter { $0.priority == .high && $0.isCompleted }.count }
}
