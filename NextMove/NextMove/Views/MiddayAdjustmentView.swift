import SwiftUI

struct MiddayAdjustmentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showAddGoal = false
    @State private var selectedGoal: Goal?

    private var today: DayLog { appState.dayLogStore.today }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "sun.max.fill")
                                .foregroundStyle(Theme.warning)
                            Text("Midday check-in")
                                .font(.nmLabel)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Text("Are these still your priorities?")
                            .font(.nmTitleHero)
                            .foregroundStyle(Theme.textPrimary)
                        Text("Keep, complete, or swap what no longer matches your day.")
                            .font(.nmBody)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if today.goals.isEmpty {
                        SectionCard {
                            Text("No goals yet. Add one to anchor your afternoon.")
                                .font(.nmBody)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    } else {
                        SectionCard {
                            VStack(spacing: 10) {
                                ForEach(today.goals) { goal in
                                    GoalRow(
                                        goal: goal,
                                        onToggle: { appState.toggleComplete(goal) },
                                        onTap: { selectedGoal = goal }
                                    )
                                }
                            }
                        }
                    }

                    Button {
                        showAddGoal = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add an afternoon goal")
                        }
                        .font(.nmLabel)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12).fill(Theme.accentSecondary.opacity(0.15))
                        )
                        .foregroundStyle(Theme.accentSecondary)
                    }
                    .buttonStyle(.plain)

                    Button {
                        appState.markMiddayAdjustmentDone()
                        dismiss()
                    } label: {
                        Text("Priorities confirmed")
                            .font(.nmLabel)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.accentGradient)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(18)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showAddGoal) {
                AddGoalView(defaultPeriod: .midday)
                    .environmentObject(appState)
            }
            .sheet(item: $selectedGoal) { goal in
                AddGoalView(editing: goal)
                    .environmentObject(appState)
            }
        }
    }
}
