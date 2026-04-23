import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.intenseGradient.ignoresSafeArea()
                Form {
                    sessionSection
                    feedbackSection
                    notificationsSection
                    aboutSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var sessionSection: some View {
        Section {
            Toggle(isOn: $settingsStore.settings.strictMode) {
                Label("Strict Mode", systemImage: "shield.lefthalf.filled")
            }
            .tint(Theme.danger)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Default Duration", systemImage: "timer")
                    Spacer()
                    Text("\(Int(settingsStore.settings.defaultDuration / 60)) min")
                        .foregroundStyle(Theme.accent)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                Slider(value: Binding(
                    get: { settingsStore.settings.defaultDuration / 60 },
                    set: { settingsStore.setDuration($0 * 60) }
                ), in: 1...120, step: 1)
                .tint(Theme.accent)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Grace Period", systemImage: "hourglass")
                    Spacer()
                    Text("\(Int(settingsStore.settings.gracePeriod))s")
                        .foregroundStyle(Theme.accent)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                Slider(value: Binding(
                    get: { settingsStore.settings.gracePeriod },
                    set: { settingsStore.setGracePeriod($0) }
                ), in: 0...10, step: 1)
                .tint(Theme.accent)
                .disabled(settingsStore.settings.strictMode)
                .opacity(settingsStore.settings.strictMode ? 0.4 : 1)
            }
        } header: {
            sectionHeader("SESSION")
        } footer: {
            Text(settingsStore.settings.strictMode
                 ? "Strict mode disables grace and fails immediately on app exit."
                 : "Grace period gives you a few seconds to return before failing.")
                .foregroundStyle(Theme.textMuted)
        }
        .listRowBackground(Theme.surface)
    }

    private var feedbackSection: some View {
        Section {
            Toggle(isOn: $settingsStore.settings.hapticsEnabled) {
                Label("Haptic Feedback", systemImage: "iphone.radiowaves.left.and.right")
            }
            .tint(Theme.accent)
            Toggle(isOn: $settingsStore.settings.soundEnabled) {
                Label("Background Sound", systemImage: "speaker.wave.2.fill")
            }
            .tint(Theme.accent)
        } header: {
            sectionHeader("FEEDBACK")
        } footer: {
            Text("Add a focus_loop.m4a file to the bundle to enable ambient sound.")
                .foregroundStyle(Theme.textMuted)
        }
        .listRowBackground(Theme.surface)
    }

    private var notificationsSection: some View {
        Section {
            Toggle(isOn: $settingsStore.settings.dailyReminderEnabled) {
                Label("Daily Reminder", systemImage: "bell.badge.fill")
            }
            .tint(Theme.accent)

            if settingsStore.settings.dailyReminderEnabled {
                DatePicker(
                    "Reminder Time",
                    selection: Binding(
                        get: {
                            var c = DateComponents()
                            c.hour = settingsStore.settings.dailyReminderHour
                            c.minute = settingsStore.settings.dailyReminderMinute
                            return Calendar.current.date(from: c) ?? Date()
                        },
                        set: { newDate in
                            let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                            settingsStore.settings.dailyReminderHour = c.hour ?? 9
                            settingsStore.settings.dailyReminderMinute = c.minute ?? 0
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .tint(Theme.accent)
            }
        } header: {
            sectionHeader("NOTIFICATIONS")
        }
        .listRowBackground(Theme.surface)
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("1.0.0").foregroundStyle(Theme.textMuted)
            }
        } header: {
            sectionHeader("ABOUT")
        }
        .listRowBackground(Theme.surface)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .heavy, design: .rounded))
            .tracking(2)
            .foregroundStyle(Theme.textMuted)
    }
}
