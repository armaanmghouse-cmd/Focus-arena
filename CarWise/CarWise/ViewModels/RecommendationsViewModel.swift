import Foundation
import SwiftUI

@MainActor
final class RecommendationsViewModel: ObservableObject {

    @Published var recommendations: [Recommendation] = []
    @Published var isLoading = false
    @Published var generatedAt: Date?

    // Compare selection
    @Published var compareSelection: Set<String> = []
    var canOpenCompare: Bool { compareSelection.count >= 2 && compareSelection.count <= 3 }

    func generate(for profile: UserProfile) async {
        isLoading = true
        // Simulate a tiny delay so the UI feels considered.
        try? await Task.sleep(nanoseconds: 450_000_000)
        let result = RecommendationEngine.recommend(for: profile, maxResults: 5)
        self.recommendations = result
        self.generatedAt = Date()
        self.isLoading = false
    }

    func toggleCompare(carId: String) {
        if compareSelection.contains(carId) {
            compareSelection.remove(carId)
        } else if compareSelection.count < 3 {
            compareSelection.insert(carId)
        }
    }

    func clearCompare() { compareSelection.removeAll() }

    var comparedCars: [Car] {
        compareSelection.compactMap { MockCarDatabase.car(id: $0) }
    }
}
