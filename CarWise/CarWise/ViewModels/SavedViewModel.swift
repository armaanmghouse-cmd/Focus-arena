import Foundation
import SwiftUI

@MainActor
final class SavedViewModel: ObservableObject {

    enum Filter: String, CaseIterable, Identifiable {
        case all, topChoices
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .all: return "All saved"
            case .topChoices: return "Top choices"
            }
        }
    }

    @Published var filter: Filter = .all

    unowned let appState: AppState
    init(appState: AppState) { self.appState = appState }

    var items: [(SavedCar, Car)] {
        let source: [SavedCar]
        switch filter {
        case .all: source = appState.savedCars
        case .topChoices: source = appState.savedCars.filter { $0.isTopChoice }
        }
        let pairs: [(SavedCar, Car)] = source.compactMap { saved in
            guard let car = MockCarDatabase.car(id: saved.id) else { return nil }
            return (saved, car)
        }
        return pairs.sorted { $0.0.savedAt > $1.0.savedAt }
    }
}
