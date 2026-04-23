import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var recsVM = RecommendationsViewModel()
    @State private var showingEditProfile = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    hero
                    if let booking = appState.upcomingBooking {
                        upcomingBookingCard(booking)
                    }
                    topPicksSection
                    profileCard
                    quickActions
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Theme.Palette.surface.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("CARWISE")
                        .font(.system(size: 13, weight: .black))
                        .tracking(3.0)
                        .foregroundColor(Theme.Palette.ink)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingEditProfile = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(Theme.Palette.ink)
                    }
                }
            }
        }
        .task {
            if recsVM.recommendations.isEmpty {
                await recsVM.generate(for: appState.profile)
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileSheet()
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("GOOD \(greetingSuffix)")
                        .font(.system(size: 11, weight: .black))
                        .tracking(2.5)
                        .foregroundColor(Theme.Palette.inkSecondary)
                    Text("Your matches.")
                        .font(Theme.Font.display(34))
                        .foregroundColor(Theme.Palette.ink)
                    Text("Budget \(appState.profile.budgetSummary) · \(appState.profile.vehicleTypes.isEmpty ? "Open to types" : appState.profile.vehicleTypes.map { $0.displayName }.sorted().joined(separator: ", "))")
                        .font(Theme.Font.body(13))
                        .foregroundColor(Theme.Palette.inkSecondary)
                }
                Spacer()
            }
            HStack(spacing: 10) {
                statTile(value: "\(recsVM.recommendations.count)", label: "MATCHES")
                statTile(value: "\(appState.savedCars.count)", label: "SAVED")
                statTile(value: "\(appState.bookings.filter { $0.status == .confirmed }.count)", label: "CALLS")
            }
        }
        .padding(18)
        .background(Theme.Palette.paper)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius).stroke(Theme.Palette.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius))
    }

    private var greetingSuffix: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "MORNING"
        case 12..<17: return "AFTERNOON"
        case 17..<22: return "EVENING"
        default: return "EVENING"
        }
    }

    private func statTile(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(Theme.Font.display(26))
                .foregroundColor(Theme.Palette.ink)
            Text(label)
                .font(.system(size: 9, weight: .black)).tracking(0.9)
                .foregroundColor(Theme.Palette.inkTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Theme.Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Upcoming booking banner

    private func upcomingBookingCard(_ booking: Booking) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "phone.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Theme.Palette.accent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text("CONSULT SCHEDULED")
                    .font(.system(size: 10, weight: .black)).tracking(1.5)
                    .foregroundColor(Theme.Palette.accent)
                Text(longDateFormatter.string(from: booking.date))
                    .font(Theme.Font.title(15))
                    .foregroundColor(Theme.Palette.ink)
                Text(booking.topic.displayName)
                    .font(Theme.Font.caption(12))
                    .foregroundColor(Theme.Palette.inkSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Theme.Palette.paper)
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Theme.Palette.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var longDateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d · h:mm a"
        return f
    }

    // MARK: - Top picks

    private var topPicksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Top picks").font(Theme.Font.headline(20)).foregroundColor(Theme.Palette.ink)
                Spacer()
                Button {
                    appState.selectedTab = .recommendations
                } label: {
                    HStack(spacing: 4) {
                        Text("See all").font(.system(size: 13, weight: .semibold))
                        Image(systemName: "arrow.right").font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(Theme.Palette.accent)
                }
            }
            if recsVM.isLoading && recsVM.recommendations.isEmpty {
                ProgressView().frame(maxWidth: .infinity).padding(.vertical, 30)
            } else if recsVM.recommendations.isEmpty {
                Text("No matches yet — adjust your profile.")
                    .font(Theme.Font.body(14))
                    .foregroundColor(Theme.Palette.inkSecondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.Palette.paper)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12).stroke(Theme.Palette.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 10) {
                    ForEach(recsVM.recommendations.prefix(3)) { rec in
                        NavigationLink {
                            CarDetailView(recommendation: rec)
                        } label: {
                            CompactCarCard(car: rec.car, matchScore: rec.matchScore)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Profile card

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your profile").font(Theme.Font.headline(20)).foregroundColor(Theme.Palette.ink)
            VStack(alignment: .leading, spacing: 10) {
                profileLine(label: "Budget", value: appState.profile.budgetSummary)
                profileLine(label: "Condition", value: appState.profile.condition.displayName)
                profileLine(label: "Keeping it", value: appState.profile.ownershipLength.displayName)
                if !appState.profile.featurePriorities.isEmpty {
                    profileLine(
                        label: "Priorities",
                        value: appState.profile.featurePriorities.map { $0.displayName }.sorted().joined(separator: ", ")
                    )
                }
            }
            .cardStyle(padding: 14)

            PrimaryButton(title: "Edit profile", icon: "slider.horizontal.3", style: .outline) {
                showingEditProfile = true
            }
        }
    }

    private func profileLine(label: String, value: String) -> some View {
        HStack {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .black)).tracking(1.2)
                .foregroundColor(Theme.Palette.inkTertiary)
            Spacer()
            Text(value)
                .font(Theme.Font.body(13))
                .foregroundColor(Theme.Palette.ink)
                .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Quick actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Next steps").font(Theme.Font.headline(20)).foregroundColor(Theme.Palette.ink)
            VStack(spacing: 10) {
                actionTile(icon: "bubble.left.and.bubble.right.fill",
                           title: "Ask a question",
                           subtitle: "Reliability, comparisons, budget fit — all grounded in your profile.",
                           accent: false) {
                    appState.selectedTab = .chat
                }
                actionTile(icon: "person.fill.checkmark",
                           title: "Talk to an expert",
                           subtitle: "Book a 30-minute call with a human advisor when you're ready.",
                           accent: true) {
                    appState.selectedTab = .expert
                }
            }
        }
    }

    private func actionTile(icon: String, title: String, subtitle: String, accent: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(accent ? .white : Theme.Palette.ink)
                    .frame(width: 40, height: 40)
                    .background(accent ? Theme.Palette.accent : Theme.Palette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(Theme.Font.title(15)).foregroundColor(Theme.Palette.ink)
                    Text(subtitle).font(Theme.Font.caption(12)).foregroundColor(Theme.Palette.inkSecondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.Palette.inkTertiary)
            }
            .padding(14)
            .background(Theme.Palette.paper)
            .overlay(
                RoundedRectangle(cornerRadius: 12).stroke(Theme.Palette.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Edit profile

struct EditProfileSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var draft: UserProfile = .empty

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    VStack(alignment: .leading, spacing: 8) {
                        Text("BUDGET").font(.system(size: 10, weight: .black)).tracking(1.2)
                            .foregroundColor(Theme.Palette.inkSecondary)
                        Text(draft.budgetSummary).font(Theme.Font.display(24)).foregroundColor(Theme.Palette.ink)
                        Slider(value: $draft.budgetMin, in: 8_000...100_000, step: 1_000).tint(Theme.Palette.accent)
                        Slider(value: $draft.budgetMax, in: 12_000...150_000, step: 1_000).tint(Theme.Palette.accent)
                    }
                    .cardStyle(padding: 16)

                    chipSection(title: "Vehicle type", items: VehicleType.allCases) { v in
                        Chip(title: v.displayName, icon: v.systemImage,
                             isSelected: draft.vehicleTypes.contains(v)) {
                            if draft.vehicleTypes.contains(v) { draft.vehicleTypes.remove(v) }
                            else { draft.vehicleTypes.insert(v) }
                        }
                    }

                    chipSection(title: "Use case", items: UseCase.allCases) { u in
                        Chip(title: u.displayName, icon: u.systemImage,
                             isSelected: draft.useCases.contains(u)) {
                            if draft.useCases.contains(u) { draft.useCases.remove(u) }
                            else { draft.useCases.insert(u) }
                        }
                    }

                    chipSection(title: "Priorities (up to 3)", items: FeaturePriority.allCases) { f in
                        AccentChip(title: f.displayName, icon: f.systemImage,
                                   isSelected: draft.featurePriorities.contains(f)) {
                            if draft.featurePriorities.contains(f) {
                                draft.featurePriorities.remove(f)
                            } else if draft.featurePriorities.count < 3 {
                                draft.featurePriorities.insert(f)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("OWNERSHIP").font(.system(size: 10, weight: .black)).tracking(1.2)
                            .foregroundColor(Theme.Palette.inkSecondary)
                        FlowLayout(spacing: 8) {
                            ForEach(OwnershipLength.allCases) { l in
                                Chip(title: l.displayName, isSelected: draft.ownershipLength == l) {
                                    draft.ownershipLength = l
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Theme.Palette.paper.ignoresSafeArea())
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(Theme.Palette.inkSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        var p = draft
                        p.isComplete = true
                        p.completedAt = Date()
                        appState.profile = p
                        dismiss()
                    }
                    .foregroundColor(Theme.Palette.accent)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear { draft = appState.profile }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("FINE-TUNE").font(.system(size: 11, weight: .black)).tracking(2.0)
                .foregroundColor(Theme.Palette.accent)
            Text("Adjust anything").font(Theme.Font.display(28)).foregroundColor(Theme.Palette.ink)
        }
    }

    @ViewBuilder
    private func chipSection<Item: Identifiable, RowContent: View>(
        title: String,
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> RowContent
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased()).font(.system(size: 10, weight: .black)).tracking(1.2)
                .foregroundColor(Theme.Palette.inkSecondary)
            FlowLayout(spacing: 8) {
                ForEach(items) { item in
                    content(item)
                }
            }
        }
    }
}
