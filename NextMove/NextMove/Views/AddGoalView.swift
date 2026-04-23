import SwiftUI

struct AddGoalView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var priority: GoalPriority
    @State private var category: GoalCategory
    @State private var useDeadline: Bool
    @State private var deadline: Date
    @State private var period: GoalPeriod
    @State private var reminderFrequency: ReminderFrequency
    @State private var notes: String

    private let editingId: UUID?
    private let createdAt: Date

    init(defaultPeriod: GoalPeriod = .morning) {
        self.editingId = nil
        self._title = State(initialValue: "")
        self._priority = State(initialValue: .medium)
        self._category = State(initialValue: .personal)
        self._useDeadline = State(initialValue: false)
        self._deadline = State(initialValue: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date())
        self._period = State(initialValue: defaultPeriod)
        self._reminderFrequency = State(initialValue: .normal)
        self._notes = State(initialValue: "")
        self.createdAt = Date()
    }

    init(editing goal: Goal) {
        self.editingId = goal.id
        self._title = State(initialValue: goal.title)
        self._priority = State(initialValue: goal.priority)
        self._category = State(initialValue: goal.category)
        self._useDeadline = State(initialValue: goal.deadline != nil)
        self._deadline = State(initialValue: goal.deadline ?? Date())
        self._period = State(initialValue: goal.period)
        self._reminderFrequency = State(initialValue: goal.reminderFrequency)
        self._notes = State(initialValue: goal.notes)
        self.createdAt = goal.createdAt
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What matters today?", text: $title, axis: .vertical)
                        .font(.nmBody)
                        .lineLimit(1...3)
                }

                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(GoalPriority.allCases) { p in
                            HStack {
                                Image(systemName: p.symbol)
                                Text(p.label)
                            }
                            .tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Category") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(GoalCategory.allCases) { cat in
                                Button {
                                    category = cat
                                } label: {
                                    CategoryChip(category: cat, selected: cat == category)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }

                Section("Period") {
                    Picker("Period", selection: $period) {
                        Text("Morning").tag(GoalPeriod.morning)
                        Text("Midday").tag(GoalPeriod.midday)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Deadline") {
                    Toggle("Set a deadline", isOn: $useDeadline)
                    if useDeadline {
                        DatePicker("Time", selection: $deadline, displayedComponents: [.hourAndMinute])
                    }
                }

                Section("Reminders") {
                    Picker("Frequency", selection: $reminderFrequency) {
                        ForEach(ReminderFrequency.allCases) { freq in
                            Text(freq.label).tag(freq)
                        }
                    }
                    Text(reminderFrequencyDescription)
                        .font(.nmCaption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Section("Notes") {
                    TextField("Optional", text: $notes, axis: .vertical)
                        .lineLimit(1...5)
                }

                if editingId != nil {
                    Section {
                        Button(role: .destructive) {
                            if let goal = currentGoal() {
                                appState.deleteGoal(goal)
                            }
                            dismiss()
                        } label: {
                            Label("Delete goal", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(editingId == nil ? "New Goal" : "Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingId == nil ? "Add" : "Save") {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .bold()
                }
            }
        }
    }

    private var reminderFrequencyDescription: String {
        switch reminderFrequency {
        case .gentle: return "A light nudge every ~3 hours."
        case .normal: return "Steady nudges every ~90 minutes with escalation."
        case .urgent: return "Frequent reminders every ~45 minutes — use sparingly."
        }
    }

    private func currentGoal() -> Goal? {
        guard let editingId else { return nil }
        return appState.dayLogStore.today.goals.first(where: { $0.id == editingId })
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let goal = Goal(
            id: editingId ?? UUID(),
            title: trimmed,
            priority: priority,
            category: category,
            deadline: useDeadline ? deadline : nil,
            createdAt: createdAt,
            completedAt: currentGoal()?.completedAt,
            period: period,
            reminderFrequency: reminderFrequency,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        if editingId != nil {
            appState.updateGoal(goal)
        } else {
            appState.addGoal(goal)
        }
        dismiss()
    }
}
