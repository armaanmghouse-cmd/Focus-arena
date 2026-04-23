import SwiftUI

struct SavedView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        SavedViewContent(appState: appState)
    }
}

private struct SavedViewContent: View {
    @StateObject private var vm: SavedViewModel
    @ObservedObject var appState: AppState

    init(appState: AppState) {
        self.appState = appState
        _vm = StateObject(wrappedValue: SavedViewModel(appState: appState))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    filterBar
                    if vm.items.isEmpty {
                        emptyState
                    } else {
                        list
                    }
                }
                .padding(16)
                .padding(.bottom, 30)
            }
            .background(Theme.Palette.surface.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SAVED")
                        .font(.system(size: 12, weight: .black)).tracking(2.5)
                        .foregroundColor(Theme.Palette.ink)
                }
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("YOUR SHORTLIST")
                .font(.system(size: 11, weight: .black)).tracking(1.8)
                .foregroundColor(Theme.Palette.accent)
            Text("\(appState.savedCars.count) saved")
                .font(Theme.Font.display(32))
                .foregroundColor(Theme.Palette.ink)
        }
    }

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(SavedViewModel.Filter.allCases) { f in
                Chip(title: f.displayName, isSelected: vm.filter == f) {
                    vm.filter = f
                }
            }
            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bookmark")
                .font(.system(size: 38, weight: .semibold))
                .foregroundColor(Theme.Palette.inkTertiary)
            Text("No saved cars yet")
                .font(Theme.Font.title(16))
                .foregroundColor(Theme.Palette.ink)
            Text("Save cars from Recommendations to start a shortlist here.")
                .font(Theme.Font.body(13))
                .foregroundColor(Theme.Palette.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 50)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private var list: some View {
        VStack(spacing: 12) {
            ForEach(vm.items, id: \.0.id) { saved, car in
                NavigationLink {
                    // Build a lightweight recommendation on the fly for the detail view.
                    CarDetailView(recommendation: syntheticRec(for: car))
                } label: {
                    SavedCarRow(saved: saved, car: car,
                                toggleTop: { appState.toggleTopChoice(carId: car.id) },
                                remove: { appState.toggleSaved(carId: car.id) })
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func syntheticRec(for car: Car) -> Recommendation {
        let breakdown = RecommendationEngine.score(car: car, profile: appState.profile)
        return Recommendation(
            car: car,
            matchScore: breakdown.matchScore,
            bestValueScore: breakdown.bestValueScore,
            confidence: breakdown.confidence,
            reasoning: "",  // detail view generates a live reasoning block
            matchHighlights: []
        )
    }
}

private struct SavedCarRow: View {
    let saved: SavedCar
    let car: Car
    let toggleTop: () -> Void
    let remove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(Theme.Palette.surface)
                    Image(systemName: car.symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Theme.Palette.ink)
                }
                .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(car.displayName).font(Theme.Font.title(15))
                            .foregroundColor(Theme.Palette.ink)
                        if saved.isTopChoice {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.Palette.accent)
                        }
                    }
                    Text(car.priceDisplay + " · " + car.type.displayName)
                        .font(Theme.Font.caption(12))
                        .foregroundColor(Theme.Palette.inkSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.Palette.inkTertiary)
            }
            .padding(14)

            if !saved.notes.isEmpty {
                Text(saved.notes)
                    .font(Theme.Font.body(13))
                    .foregroundColor(Theme.Palette.inkSecondary)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 0) {
                Button(action: toggleTop) {
                    HStack(spacing: 6) {
                        Image(systemName: saved.isTopChoice ? "star.fill" : "star")
                        Text(saved.isTopChoice ? "Top choice" : "Make top")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(saved.isTopChoice ? Theme.Palette.accent : Theme.Palette.ink)
                    .frame(maxWidth: .infinity, minHeight: 40)
                }
                .buttonStyle(PressableButtonStyle())
                Divider().frame(height: 40)
                Button(action: remove) {
                    HStack(spacing: 6) {
                        Image(systemName: "bookmark.slash")
                        Text("Remove")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.Palette.inkSecondary)
                    .frame(maxWidth: .infinity, minHeight: 40)
                }
                .buttonStyle(PressableButtonStyle())
            }
            .background(Theme.Palette.surface)
            .overlay(
                Rectangle().frame(height: 1).foregroundColor(Theme.Palette.border),
                alignment: .top
            )
        }
        .background(Theme.Palette.paper)
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Theme.Palette.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
