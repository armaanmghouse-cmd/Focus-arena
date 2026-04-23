import Foundation
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {

    enum Step: Int, CaseIterable {
        case welcome, budget, vehicleType, condition, useCase, features, ownership, brands, review

        var title: String {
            switch self {
            case .welcome: return "Welcome"
            case .budget: return "Budget"
            case .vehicleType: return "Vehicle Type"
            case .condition: return "New or Used"
            case .useCase: return "How you'll use it"
            case .features: return "What matters most"
            case .ownership: return "How long you'll keep it"
            case .brands: return "Brand preferences"
            case .review: return "Review"
            }
        }

        var progressShown: Bool {
            !(self == .welcome)
        }
    }

    @Published var step: Step = .welcome
    @Published var draft: UserProfile = .empty

    let totalProgressSteps = Step.allCases.count - 2 // exclude welcome + review
    var currentProgressStep: Int {
        max(0, step.rawValue - 1) // budget starts at 1
    }

    var progress: Double {
        guard step.progressShown else { return 0 }
        return Double(currentProgressStep) / Double(totalProgressSteps)
    }

    func next() {
        guard let nextStep = Step(rawValue: step.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            step = nextStep
        }
    }

    func back() {
        guard let prev = Step(rawValue: step.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            step = prev
        }
    }

    func skip() { next() }

    // Quick conveniences
    func toggle(_ type: VehicleType) {
        if draft.vehicleTypes.contains(type) { draft.vehicleTypes.remove(type) }
        else { draft.vehicleTypes.insert(type) }
    }

    func toggle(_ useCase: UseCase) {
        if draft.useCases.contains(useCase) { draft.useCases.remove(useCase) }
        else { draft.useCases.insert(useCase) }
    }

    func toggle(_ feature: FeaturePriority) {
        if draft.featurePriorities.contains(feature) { draft.featurePriorities.remove(feature) }
        else { draft.featurePriorities.insert(feature) }
    }

    func toggle(brand: String) {
        if draft.preferredBrands.contains(brand) { draft.preferredBrands.remove(brand) }
        else { draft.preferredBrands.insert(brand) }
    }

    // Minimum viable profile = budget set + at least one vehicle type OR use case
    var canSubmit: Bool {
        draft.budgetMax > draft.budgetMin &&
        (!draft.vehicleTypes.isEmpty || !draft.useCases.isEmpty)
    }
}
