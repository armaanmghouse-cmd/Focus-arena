import Foundation
import Combine
import SwiftUI

final class AppState: ObservableObject {
    let settingsStore: SettingsStore
    let dayLogStore: DayLogStore

    @Published var showMiddayPrompt: Bool = false
    @Published var showReflectionPrompt: Bool = false
    @Published var showScoreCelebration: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init(settingsStore: SettingsStore = SettingsStore(), dayLogStore: DayLogStore = DayLogStore()) {
        self.settingsStore = settingsStore
        self.dayLogStore = dayLogStore

        settingsStore.$settings
            .sink { [weak self] settings in
                self?.applySettings(settings)
            }
            .store(in: &cancellables)

        dayLogStore.$logs
            .sink { [weak self] _ in
                guard let self else { return }
                NotificationManager.shared.reschedule(
                    goals: self.dayLogStore.today.goals,
                    settings: self.settingsStore.settings
                )
            }
            .store(in: &cancellables)
    }

    func applySettings(_ settings: AppSettings) {
        if settings.notificationsEnabled {
            NotificationManager.shared.scheduleNightReflection(settings: settings)
            NotificationManager.shared.scheduleMiddayAdjustment(settings: settings)
        } else {
            NotificationManager.shared.cancelAllDailyAnchors()
            NotificationManager.shared.cancelAllGoalReminders()
        }
    }

    // MARK: - Goal operations (delegated to DayLogStore)

    func addGoal(_ goal: Goal) {
        dayLogStore.updateToday { log in
            log.goals.append(goal)
        }
        NotificationManager.shared.scheduleReminders(for: goal, settings: settingsStore.settings)
    }

    func updateGoal(_ goal: Goal) {
        dayLogStore.updateToday { log in
            if let idx = log.goals.firstIndex(where: { $0.id == goal.id }) {
                log.goals[idx] = goal
            }
        }
        NotificationManager.shared.scheduleReminders(for: goal, settings: settingsStore.settings)
    }

    func deleteGoal(_ goal: Goal) {
        dayLogStore.updateToday { log in
            log.goals.removeAll(where: { $0.id == goal.id })
        }
        NotificationManager.shared.cancelReminders(for: goal.id)
    }

    func toggleComplete(_ goal: Goal) {
        dayLogStore.updateToday { log in
            guard let idx = log.goals.firstIndex(where: { $0.id == goal.id }) else { return }
            if log.goals[idx].isCompleted {
                log.goals[idx].completedAt = nil
            } else {
                log.goals[idx].completedAt = Date()
            }
        }
        if !goal.isCompleted {
            NotificationManager.shared.cancelReminders(for: goal.id)
        } else {
            var mutable = goal
            mutable.completedAt = nil
            NotificationManager.shared.scheduleReminders(for: mutable, settings: settingsStore.settings)
        }
    }

    // MARK: - Reflection

    func saveReflection(_ reflection: Reflection) {
        var final = reflection
        final.tags = AnalyticsService.extractTags(from: reflection.regret)
        dayLogStore.updateToday { log in
            log.reflection = final
        }
    }

    func markMiddayAdjustmentDone() {
        dayLogStore.updateToday { log in
            log.middayAdjustmentDone = true
        }
    }

    // MARK: - Prompting logic

    func checkPrompts() {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let settings = settingsStore.settings
        let today = dayLogStore.today

        if !today.middayAdjustmentDone,
           hour >= settings.middayAdjustmentHour,
           hour < settings.nightReflectionHour,
           !today.goals.isEmpty {
            showMiddayPrompt = true
        }

        let reflectionEmpty = today.reflection?.isEmpty ?? true
        if reflectionEmpty, hour >= settings.nightReflectionHour {
            showReflectionPrompt = true
        }
    }

    // MARK: - Suggested goals from past regrets

    func suggestedGoals() -> [Goal] {
        let patterns = AnalyticsService.patterns(from: dayLogStore.allReflections(), minCount: 2, limit: 5)
        return AnalyticsService.suggestedGoals(from: patterns)
    }
}
