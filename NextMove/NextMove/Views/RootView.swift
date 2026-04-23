import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            AnalyticsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.xaxis")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Theme.accent)
        .sheet(isPresented: $appState.showMiddayPrompt) {
            MiddayAdjustmentView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $appState.showReflectionPrompt) {
            ReflectionView()
                .environmentObject(appState)
        }
        .onAppear {
            appState.checkPrompts()
        }
    }
}
