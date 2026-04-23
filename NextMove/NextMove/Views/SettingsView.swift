import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    private var settingsBinding: Binding<AppSettings> {
        Binding(
            get: { appState.settingsStore.settings },
            set: { appState.settingsStore.settings = $0 }
        )
    }

    private var reflectionTime: Binding<Date> {
        Binding(
            get: {
                var comps = DateComponents()
                comps.hour = appState.settingsStore.settings.nightReflectionHour
                comps.minute = appState.settingsStore.settings.nightReflectionMinute
                return Calendar.current.date(from: comps) ?? Date()
            },
            set: { newValue in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                appState.settingsStore.settings.nightReflectionHour = comps.hour ?? 21
                appState.settingsStore.settings.nightReflectionMinute = comps.minute ?? 30
            }
        )
    }

    private var middayTime: Binding<Date> {
        Binding(
            get: {
                var comps = DateComponents()
                comps.hour = appState.settingsStore.settings.middayAdjustmentHour
                comps.minute = appState.settingsStore.settings.middayAdjustmentMinute
                return Calendar.current.date(from: comps) ?? Date()
            },
            set: { newValue in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                appState.settingsStore.settings.middayAdjustmentHour = comps.hour ?? 13
                appState.settingsStore.settings.middayAdjustmentMinute = comps.minute ?? 0
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Notifications") {
                    Toggle("Enable reminders", isOn: settingsBinding.notificationsEnabled)
                    Picker("Default frequency", selection: settingsBinding.globalReminderFrequency) {
                        ForEach(ReminderFrequency.allCases) { freq in
                            Text(freq.label).tag(freq)
                        }
                    }
                }

                Section("Daily anchors") {
                    DatePicker("Midday check-in", selection: middayTime, displayedComponents: [.hourAndMinute])
                    DatePicker("Night reflection", selection: reflectionTime, displayedComponents: [.hourAndMinute])
                }

                Section("Quiet hours") {
                    Stepper("Start: \(formatHour(appState.settingsStore.settings.quietStartHour))", value: settingsBinding.quietStartHour, in: 0...23)
                    Stepper("End: \(formatHour(appState.settingsStore.settings.quietEndHour))", value: settingsBinding.quietEndHour, in: 0...23)
                    Text("No reminders fire during quiet hours.")
                        .font(.nmCaption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Section("Appearance") {
                    Toggle("Dark mode", isOn: settingsBinding.useDarkMode)
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    Link("Grant notification access", destination: URL(string: UIApplication.openSettingsURLString)!)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func formatHour(_ hour: Int) -> String {
        var comps = DateComponents()
        comps.hour = hour
        guard let date = Calendar.current.date(from: comps) else { return "\(hour):00" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }
}
