import SwiftUI

struct ReflectionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var regret: String = ""
    @State private var win: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.nightGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        header

                        VStack(alignment: .leading, spacing: 8) {
                            Text("What do you regret not doing today?")
                                .font(.nmTitleSection)
                                .foregroundStyle(.white)
                            TextEditor(text: $regret)
                                .font(.nmBody)
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 120)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.08))
                                )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("What would make tomorrow a win?")
                                .font(.nmTitleSection)
                                .foregroundStyle(.white)
                            TextEditor(text: $win)
                                .font(.nmBody)
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 120)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.08))
                                )
                        }

                        Button {
                            save()
                        } label: {
                            Text("Save reflection")
                                .font(.nmLabel)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Theme.accentGradient)
                                )
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                        .disabled(regret.trimmingCharacters(in: .whitespaces).isEmpty &&
                                  win.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity((regret.trimmingCharacters(in: .whitespaces).isEmpty &&
                                  win.trimmingCharacters(in: .whitespaces).isEmpty) ? 0.5 : 1)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Night reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .preferredColorScheme(.dark)
            .onAppear {
                if let existing = appState.dayLogStore.today.reflection {
                    regret = existing.regret
                    win = existing.win
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(Theme.accent)
                Text("Close out the day")
                    .font(.nmLabel)
                    .foregroundStyle(Color.white.opacity(0.7))
            }
            Text("Tomorrow is built tonight.")
                .font(.nmTitleHero)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func save() {
        let reflection = Reflection(
            date: Date(),
            regret: regret.trimmingCharacters(in: .whitespacesAndNewlines),
            win: win.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        appState.saveReflection(reflection)
        dismiss()
    }
}
