import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                mainTabs
            } else {
                OnboardingFlowView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appState.hasCompletedOnboarding)
    }

    private var mainTabs: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(AppTab.home)

            RecommendationsView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Matches")
                }
                .tag(AppTab.recommendations)

            ChatView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Chat")
                }
                .tag(AppTab.chat)

            SavedView()
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Saved")
                }
                .tag(AppTab.saved)

            ExpertView()
                .tabItem {
                    Image(systemName: "person.fill.checkmark")
                    Text("Expert")
                }
                .tag(AppTab.expert)
        }
        .tint(Theme.Palette.accent)
    }
}
