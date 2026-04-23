import SwiftUI

struct TodayView: View {
    @EnvironmentObject var appState: AppState

    @State private var showAddGoal = false
    @State private var showScore = false
    @State private var selectedGoal: Goal?
    @State private var defaultPeriod: GoalPeriod = .morning

    private var today: DayLog { appState.dayLogStore.today }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    progressCard
                    suggestedGoalsSection
                    goalsList
                    reflectionEntry
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle(greetingTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        defaultPeriod = currentPeriodSuggestion()
                        showAddGoal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showAddGoal) {
                AddGoalView(defaultPeriod: defaultPeriod)
                    .environmentObject(appState)
            }
            .sheet(item: $selectedGoal) { goal in
                AddGoalView(editing: goal)
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showScore) {
                ScoreView()
                    .environmentObject(appState)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date(), style: .date)
                .font(.nmCaption)
                .foregroundStyle(Theme.textSecondary)
            Text(motivationalLine)
                .font(.nmBody)
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressCard: some View {
        SectionCard {
            HStack(spacing: 20) {
                ZStack {
                    ProgressRing(progress: today.completionRatio, size: 96)
                    VStack(spacing: 2) {
                        Text(today.progressText)
                            .font(.system(size: 22, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(Theme.textPrimary)
                        Text("goals")
                            .font(.nmCaption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Today's momentum")
                        .font(.nmLabel)
                        .foregroundStyle(Theme.textSecondary)
                    Text("\(Int(today.completionRatio * 100))%")
                        .font(.system(size: 40, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(Theme.accent)

                    Button {
                        showScore = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("See score")
                                .font(.nmLabel)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundStyle(Theme.accent)
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 0)
            }
        }
    }

    @ViewBuilder
    private var suggestedGoalsSection: some View {
        let suggestions = appState.suggestedGoals()
        if !suggestions.isEmpty, today.goals.isEmpty {
            SectionCard(title: "From your past regrets", subtitle: "Tap to add") {
                VStack(spacing: 8) {
                    ForEach(suggestions) { suggestion in
                        Button {
                            appState.addGoal(suggestion)
                        } label: {
                            HStack {
                                Image(systemName: suggestion.category.symbol)
                                    .foregroundStyle(suggestion.category.color)
                                Text(suggestion.title)
                                    .font(.nmBody)
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(Theme.accent)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12).fill(Theme.surfaceElevated)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var goalsList: some View {
        if today.goals.isEmpty {
            emptyState
        } else {
            let morning = today.goals.filter { $0.period == .morning }
            let midday = today.goals.filter { $0.period == .midday }

            if !morning.isEmpty {
                SectionCard(title: "Morning plan", subtitle: "What you set out to do") {
                    VStack(spacing: 10) {
                        ForEach(morning) { goal in
                            GoalRow(
                                goal: goal,
                                onToggle: { appState.toggleComplete(goal) },
                                onTap: { selectedGoal = goal }
                            )
                            .contextMenu {
                                Button(role: .destructive) {
                                    appState.deleteGoal(goal)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }

            if !midday.isEmpty {
                SectionCard(title: "Midday adjustments", subtitle: "Added during the day") {
                    VStack(spacing: 10) {
                        ForEach(midday) { goal in
                            GoalRow(
                                goal: goal,
                                onToggle: { appState.toggleComplete(goal) },
                                onTap: { selectedGoal = goal }
                            )
                            .contextMenu {
                                Button(role: .destructive) {
                                    appState.deleteGoal(goal)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        SectionCard {
            VStack(spacing: 12) {
                Image(systemName: "target")
                    .font(.system(size: 42, weight: .medium))
                    .foregroundStyle(Theme.accentGradient)
                Text("Plan your day")
                    .font(.nmTitleSection)
                    .foregroundStyle(Theme.textPrimary)
                Text("Add 1–3 goals that would make today a win. Small steps beat perfect plans.")
                    .font(.nmBody)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                Button {
                    defaultPeriod = .morning
                    showAddGoal = true
                } label: {
                    Text("Add first goal")
                        .font(.nmLabel)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.accentGradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
    }

    @ViewBuilder
    private var reflectionEntry: some View {
        if !today.goals.isEmpty {
            let hasReflection = !(today.reflection?.isEmpty ?? true)
            Button {
                appState.showReflectionPrompt = true
            } label: {
                HStack {
                    Image(systemName: hasReflection ? "moon.stars.fill" : "moon.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Theme.nightAccent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(hasReflection ? "Reflection saved" : "Nightly reflection")
                            .font(.nmLabel)
                            .foregroundStyle(Theme.textPrimary)
                        Text(hasReflection ? "Tap to review" : "Close out the day")
                            .font(.nmCaption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.textMuted)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Theme.surface)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var greetingTitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Late night"
        }
    }

    private var motivationalLine: String {
        if today.goals.isEmpty {
            return "What would make today a win?"
        } else if today.completionRatio == 1 {
            return "Day's plan complete. Well done."
        } else {
            return "Stay aligned. One move at a time."
        }
    }

    private func currentPeriodSuggestion() -> GoalPeriod {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 12 ? .midday : .morning
    }
}
