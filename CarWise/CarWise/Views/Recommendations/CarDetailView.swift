import SwiftUI

struct CarDetailView: View {
    let recommendation: Recommendation
    @EnvironmentObject private var appState: AppState
    @State private var noteDraft: String = ""
    @State private var showingNoteSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero
                scoresCard
                reasoningCard
                prosConsCard
                specsCard
                actionRow
            }
            .padding(16)
        }
        .background(Theme.Palette.surface.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.toggleSaved(carId: recommendation.car.id)
                } label: {
                    Image(systemName: appState.isSaved(carId: recommendation.car.id) ? "bookmark.fill" : "bookmark")
                        .foregroundColor(appState.isSaved(carId: recommendation.car.id) ? Theme.Palette.accent : Theme.Palette.ink)
                }
            }
        }
        .sheet(isPresented: $showingNoteSheet) {
            NoteEditorSheet(carId: recommendation.car.id,
                            carName: recommendation.car.displayName,
                            initialNote: appState.saved(for: recommendation.car.id)?.notes ?? "")
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                RedPill(text: recommendation.car.type.displayName)
                if recommendation.bestValueScore >= 80 { InkPill(text: "Best value") }
                Spacer()
            }
            Text(recommendation.car.displayName)
                .font(Theme.Font.display(34))
                .foregroundColor(Theme.Palette.ink)
            Text(recommendation.car.yearRange + " · " + recommendation.car.priceDisplay)
                .font(Theme.Font.body(14))
                .foregroundColor(Theme.Palette.inkSecondary)
            Text(recommendation.car.summary)
                .font(Theme.Font.body(15))
                .foregroundColor(Theme.Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
            FlowLayout(spacing: 6) {
                ForEach(recommendation.matchHighlights, id: \.self) { h in
                    Text(h)
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Theme.Palette.surface)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.Palette.border, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .foregroundColor(Theme.Palette.ink)
                }
            }
        }
        .cardStyle(padding: 18)
    }

    // MARK: - Scores

    private var scoresCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SCORES").font(.system(size: 10, weight: .black)).tracking(1.2)
                    .foregroundColor(Theme.Palette.inkTertiary)
                Text("At a glance").font(Theme.Font.headline(18)).foregroundColor(Theme.Palette.ink)
            }
            Spacer()
            VStack(spacing: 2) {
                ScoreRing(score: recommendation.matchScore, label: "MATCH", size: 60)
            }
            VStack(spacing: 2) {
                ScoreRing(score: recommendation.bestValueScore, label: "VALUE", size: 60)
            }
            VStack(spacing: 2) {
                ScoreRing(score: recommendation.confidence, label: "CONF.", size: 60)
            }
        }
        .cardStyle(padding: 16)
    }

    // MARK: - Reasoning

    private var reasoningCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
                    .background(Theme.Palette.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Text("AI Reasoning")
                    .font(Theme.Font.headline(18))
                    .foregroundColor(Theme.Palette.ink)
            }
            Text(recommendation.reasoning)
                .font(Theme.Font.body(14))
                .foregroundColor(Theme.Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardStyle(padding: 16)
    }

    // MARK: - Pros/Cons

    private var prosConsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What you'll like / dislike")
                .font(Theme.Font.headline(18))
                .foregroundColor(Theme.Palette.ink)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(recommendation.car.pros, id: \.self) { p in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Theme.Palette.success)
                        Text(p).font(Theme.Font.body(14)).foregroundColor(Theme.Palette.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                ForEach(recommendation.car.cons, id: \.self) { c in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Theme.Palette.accent)
                        Text(c).font(Theme.Font.body(14)).foregroundColor(Theme.Palette.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .cardStyle(padding: 16)
    }

    // MARK: - Specs

    private var specsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Specs").font(Theme.Font.headline(18)).foregroundColor(Theme.Palette.ink)

            VStack(spacing: 10) {
                ScoreBar(label: "Reliability", score: recommendation.car.reliabilityScore,
                         color: Theme.Palette.ink)
                ScoreBar(label: "Fuel economy", score: recommendation.car.fuelEconomyScore,
                         color: Theme.Palette.ink)
                ScoreBar(label: "Tech", score: recommendation.car.techScore, color: Theme.Palette.ink)
                ScoreBar(label: "Luxury", score: recommendation.car.luxuryScore, color: Theme.Palette.ink)
                ScoreBar(label: "Safety", score: recommendation.car.safetyScore, color: Theme.Palette.ink)
                ScoreBar(label: "Performance", score: recommendation.car.performanceScore, color: Theme.Palette.accent)
                ScoreBar(label: "Cargo", score: recommendation.car.cargoScore, color: Theme.Palette.ink)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                specRow("MPG", recommendation.car.mpgDisplay)
                specRow("Horsepower", "\(recommendation.car.horsepower) hp")
                specRow("Drivetrain", recommendation.car.drivetrain)
                specRow("Transmission", recommendation.car.transmission)
                specRow("Seats", "\(recommendation.car.seatingCapacity)")
                specRow("Cargo", String(format: "%.1f cu ft", recommendation.car.cargoCubicFeet))
                specRow("Availability", recommendation.car.availability.map { $0.displayName }.joined(separator: ", "))
            }
        }
        .cardStyle(padding: 16)
    }

    private func specRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .black)).tracking(1.2)
                .foregroundColor(Theme.Palette.inkTertiary)
            Spacer()
            Text(value)
                .font(Theme.Font.mono(13))
                .foregroundColor(Theme.Palette.ink)
        }
    }

    // MARK: - Actions

    private var actionRow: some View {
        VStack(spacing: 10) {
            if appState.isSaved(carId: recommendation.car.id) {
                PrimaryButton(title: "Edit notes", icon: "note.text", style: .outline) {
                    showingNoteSheet = true
                }
                Button {
                    appState.toggleTopChoice(carId: recommendation.car.id)
                } label: {
                    HStack {
                        Image(systemName: (appState.saved(for: recommendation.car.id)?.isTopChoice ?? false) ? "star.fill" : "star")
                        Text((appState.saved(for: recommendation.car.id)?.isTopChoice ?? false)
                             ? "Top choice"
                             : "Mark as top choice")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Palette.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            } else {
                AccentButton(title: "Save this car", icon: "bookmark.fill") {
                    appState.toggleSaved(carId: recommendation.car.id)
                }
            }
            Button {
                appState.selectedTab = .expert
            } label: {
                Text("Not sure? Talk to an expert →")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.Palette.inkSecondary)
            }
            .padding(.top, 4)
        }
    }
}

struct NoteEditorSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let carId: String
    let carName: String
    @State var initialNote: String
    @State private var text: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $text)
                    .padding(12)
                    .background(Theme.Palette.surface)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.Palette.border, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(minHeight: 200)
                    .padding()
                Spacer()
            }
            .navigationTitle("Notes on \(carName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(Theme.Palette.inkSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        appState.updateNotes(carId: carId, notes: text)
                        dismiss()
                    }
                    .foregroundColor(Theme.Palette.accent)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear { text = initialNote }
    }
}
