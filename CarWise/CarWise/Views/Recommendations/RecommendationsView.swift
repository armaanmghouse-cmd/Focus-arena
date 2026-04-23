import SwiftUI

struct RecommendationsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = RecommendationsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    if vm.isLoading && vm.recommendations.isEmpty {
                        loadingState
                    } else if vm.recommendations.isEmpty {
                        emptyState
                    } else {
                        cards
                    }
                }
                .padding(16)
                .padding(.bottom, vm.canOpenCompare ? 90 : 20)
            }
            .background(Theme.Palette.surface.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("RECOMMENDATIONS")
                        .font(.system(size: 12, weight: .black)).tracking(2.5)
                        .foregroundColor(Theme.Palette.ink)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await vm.generate(for: appState.profile) }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Theme.Palette.ink)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if vm.canOpenCompare {
                    compareBar
                }
            }
        }
        .task {
            if vm.recommendations.isEmpty {
                await vm.generate(for: appState.profile)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(vm.recommendations.count) CARS RANKED FOR YOU")
                .font(.system(size: 11, weight: .black)).tracking(1.8)
                .foregroundColor(Theme.Palette.accent)
            Text("The shortlist.")
                .font(Theme.Font.display(32))
                .foregroundColor(Theme.Palette.ink)
            if let generatedAt = vm.generatedAt {
                Text("Generated \(relativeFormatter.localizedString(for: generatedAt, relativeTo: Date()))")
                    .font(Theme.Font.caption(12))
                    .foregroundColor(Theme.Palette.inkSecondary)
            }
            Text("Tap any card for full reasoning. Select 2–3 to compare side-by-side.")
                .font(Theme.Font.body(13))
                .foregroundColor(Theme.Palette.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }

    private var relativeFormatter: RelativeDateTimeFormatter {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short
        return f
    }

    // MARK: - States

    private var loadingState: some View {
        VStack(spacing: 14) {
            ProgressView().tint(Theme.Palette.accent)
            Text("Ranking your matches...")
                .font(Theme.Font.body(14))
                .foregroundColor(Theme.Palette.inkSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass").font(.system(size: 34)).foregroundColor(Theme.Palette.inkTertiary)
            Text("No matches inside your budget.")
                .font(Theme.Font.title(16)).foregroundColor(Theme.Palette.ink)
            Text("Try widening your budget or loosening vehicle types in your profile.")
                .font(Theme.Font.body(13)).foregroundColor(Theme.Palette.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private var cards: some View {
        VStack(spacing: 14) {
            ForEach(vm.recommendations) { rec in
                NavigationLink {
                    CarDetailView(recommendation: rec)
                } label: {
                    CarCard(
                        recommendation: rec,
                        isSaved: appState.isSaved(carId: rec.car.id),
                        isInCompare: vm.compareSelection.contains(rec.car.id),
                        onTap: {},
                        onSave: { appState.toggleSaved(carId: rec.car.id) },
                        onToggleCompare: { vm.toggleCompare(carId: rec.car.id) }
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Compare bar

    private var compareBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(vm.compareSelection.count) selected")
                    .font(.system(size: 12, weight: .bold)).foregroundColor(Theme.Palette.ink)
                Text("Max 3 cars")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.Palette.inkSecondary)
            }
            Spacer()
            Button("Clear") { vm.clearCompare() }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.Palette.inkSecondary)
            NavigationLink {
                CompareView(cars: vm.comparedCars)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "rectangle.split.2x1")
                    Text("Compare")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Theme.Palette.accent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(14)
        .background(
            Theme.Palette.paper
                .shadow(color: .black.opacity(0.15), radius: 14, x: 0, y: -4)
        )
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(Theme.Palette.border),
            alignment: .top
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }
}
