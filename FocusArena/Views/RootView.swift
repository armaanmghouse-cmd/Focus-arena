import SwiftUI

struct RootView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            switch sessionManager.phase {
            case .idle:
                MainTabsView()
                    .transition(.opacity)
            case .running, .warning:
                ActiveSessionView()
                    .transition(.opacity)
            case .succeeded(let session):
                SuccessView(session: session)
                    .transition(.opacity)
            case .failed(let session):
                FailView(session: session)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: sessionManager.phase)
        .onChange(of: scenePhase) { _, newPhase in
            sessionManager.handleScenePhaseChange(newPhase)
        }
    }
}

struct MainTabsView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Arena", systemImage: "flame.fill") }
            HistoryView()
                .tabItem { Label("History", systemImage: "list.bullet.rectangle") }
            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Theme.accent)
    }
}
