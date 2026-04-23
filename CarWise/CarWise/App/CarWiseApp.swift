import SwiftUI

@main
struct CarWiseApp: App {
    @StateObject private var appState = AppState()

    init() {
        configureTabBarAppearance()
        configureNavigationBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
                .onAppear {
                    NotificationService.shared.requestAuthorization()
                    if !appState.hasCompletedOnboarding {
                        NotificationService.shared.scheduleFinishOnboardingReminder(after: 24)
                    }
                }
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        appearance.shadowColor = UIColor(white: 0, alpha: 0.08)

        let normal = UITabBarItemAppearance()
        normal.normal.iconColor = UIColor(white: 0.55, alpha: 1)
        normal.normal.titleTextAttributes = [
            .foregroundColor: UIColor(white: 0.55, alpha: 1),
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ]
        normal.selected.iconColor = UIColor(red: 0xE1 / 255.0, green: 0x1D / 255.0, blue: 0x2A / 255.0, alpha: 1)
        normal.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0xE1 / 255.0, green: 0x1D / 255.0, blue: 0x2A / 255.0, alpha: 1),
            .font: UIFont.systemFont(ofSize: 10, weight: .black)
        ]
        appearance.stackedLayoutAppearance = normal
        appearance.inlineLayoutAppearance = normal
        appearance.compactInlineLayoutAppearance = normal

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        appearance.shadowColor = UIColor(white: 0, alpha: 0.06)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 13, weight: .black)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
