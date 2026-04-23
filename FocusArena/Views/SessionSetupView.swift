import SwiftUI

struct SessionSetupView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @EnvironmentObject private var settingsStore: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var task: String = ""
    @State private var minutes: Double = 25

    private let presetTasks = ["Study", "Workout", "Read", "Code", "Write", "Practice"]

    var body: some View {
        ZStack {
            Theme.intenseGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    taskSection
                    durationSection
                    strictToggle
                    PrimaryButton(title: "LOCK IN", icon: "lock.fill") {
                        sessionManager.start(task: trimmedTask, duration: minutes * 60)
                        dismiss()
                    }
                }
                .padding(24)
            }
        }
        .onAppear {
            minutes = max(1, settingsStore.settings.defaultDuration / 60)
        }
    }

    private var trimmedTask: String {
        task.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("PREPARE")
                .font(.labelStrong)
                .tracking(4)
                .foregroundStyle(Theme.accent)
            Text("Choose your battle.")
                .font(.titleHero)
                .foregroundStyle(Theme.textPrimary)
        }
    }

    private var taskSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TASK")
                .font(.labelStrong)
                .tracking(3)
                .foregroundStyle(Theme.textMuted)

            TextField("What are you focusing on?", text: $task)
                .textFieldStyle(.plain)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Theme.surfaceElevated)
                )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(presetTasks, id: \.self) { preset in
                        Button {
                            task = preset
                        } label: {
                            Text(preset)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(
                                    Capsule().fill(task == preset ? Theme.accent : Theme.surfaceElevated)
                                )
                                .foregroundStyle(task == preset ? .black : Theme.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("DURATION")
                    .font(.labelStrong)
                    .tracking(3)
                    .foregroundStyle(Theme.textMuted)
                Spacer()
                Text("\(Int(minutes)) min")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .contentTransition(.numericText())
            }

            Slider(value: $minutes, in: 1...120, step: 1)
                .tint(Theme.accent)

            HStack(spacing: 8) {
                ForEach([5, 15, 25, 45, 60, 90], id: \.self) { value in
                    Button {
                        withAnimation(.snappy) { minutes = Double(value) }
                    } label: {
                        Text("\(value)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(Int(minutes) == value ? Theme.accent.opacity(0.25) : Theme.surfaceElevated)
                            )
                            .foregroundStyle(Int(minutes) == value ? Theme.accent : Theme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var strictToggle: some View {
        Toggle(isOn: $settingsStore.settings.strictMode) {
            VStack(alignment: .leading, spacing: 4) {
                Text("STRICT MODE")
                    .font(.labelStrong)
                    .tracking(2)
                    .foregroundStyle(Theme.textPrimary)
                Text("No grace period. One exit and you fail.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .tint(Theme.danger)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.surface)
        )
    }
}
