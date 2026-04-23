import SwiftUI

@main
struct NextMoveApp: App {
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .tint(Theme.accent)
                .preferredColorScheme(appState.settingsStore.settings.useDarkMode ? .dark : .light)
                .onAppear {
                    appState.applySettings(appState.settingsStore.settings)
                    appState.checkPrompts()
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        appState.checkPrompts()
                    }
                }
        }
    }
}
