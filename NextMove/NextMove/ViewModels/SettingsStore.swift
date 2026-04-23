import Foundation
import Combine

final class SettingsStore: ObservableObject {
    @Published var settings: AppSettings {
        didSet { persist() }
    }

    private let filename = "nextmove.settings.json"

    init() {
        self.settings = PersistenceService.shared.load(
            AppSettings.self,
            from: "nextmove.settings.json",
            fallback: .default
        )
    }

    private func persist() {
        PersistenceService.shared.save(settings, to: filename)
    }
}
