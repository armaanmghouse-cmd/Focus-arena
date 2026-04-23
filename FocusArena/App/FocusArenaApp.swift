import SwiftUI

@main
struct FocusArenaApp: App {
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var profileStore = ProfileStore()
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var historyStore = HistoryStore()

    init() {
        NotificationService.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionManager)
                .environmentObject(profileStore)
                .environmentObject(settingsStore)
                .environmentObject(historyStore)
                .preferredColorScheme(.dark)
                .tint(Theme.accent)
                .onAppear {
                    sessionManager.bind(
                        profile: profileStore,
                        settings: settingsStore,
                        history: historyStore
                    )
                    sessionManager.recoverIfNeeded()
                }
        }
    }
}
