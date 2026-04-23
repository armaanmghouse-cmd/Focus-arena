import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = OnboardingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().foregroundColor(Theme.Palette.border)
            content
            footer
        }
        .background(Theme.Palette.paper.ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Text("CARWISE")
                    .font(.system(size: 14, weight: .black))
                    .tracking(3.0)
                    .foregroundColor(Theme.Palette.ink)
                Spacer()
                if vm.step != .welcome && vm.step != .review {
                    Button("Skip") { vm.skip() }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.Palette.inkSecondary)
                }
            }
            if vm.step.progressShown {
                progressBar
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 14)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(Theme.Palette.border).frame(height: 3)
                Rectangle().fill(Theme.Palette.accent)
                    .frame(width: geo.size.width * vm.progress, height: 3)
                    .animation(.easeOut(duration: 0.3), value: vm.progress)
            }
        }
        .frame(height: 3)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                switch vm.step {
                case .welcome:     WelcomeStep()
                case .budget:      BudgetStep(profile: $vm.draft)
                case .vehicleType: VehicleTypeStep(profile: $vm.draft, vm: vm)
                case .condition:   ConditionStep(profile: $vm.draft)
                case .useCase:     UseCaseStep(profile: $vm.draft, vm: vm)
                case .features:    FeatureStep(profile: $vm.draft, vm: vm)
                case .ownership:   OwnershipStep(profile: $vm.draft)
                case .brands:      BrandStep(profile: $vm.draft, vm: vm)
                case .review:      ReviewStep(profile: vm.draft)
                }
            }
            .padding(20)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 12) {
            if vm.step != .welcome {
                PrimaryButton(title: "Back", style: .outline) { vm.back() }
                    .frame(maxWidth: 120)
            }
            if vm.step == .review {
                AccentButton(title: "See my matches", icon: "sparkles") {
                    appState.completeOnboarding(with: vm.draft)
                }
            } else {
                AccentButton(title: vm.step == .welcome ? "Let's go" : "Continue",
                             icon: "arrow.right") {
                    vm.next()
                }
            }
        }
        .padding(20)
        .background(
            Theme.Palette.paper
                .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: -6)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Step views

private struct SectionTitle: View {
    let eyebrow: String
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow.uppercased())
                .font(.system(size: 11, weight: .black))
                .tracking(2.0)
                .foregroundColor(Theme.Palette.accent)
            Text(title)
                .font(Theme.Font.display(30))
                .foregroundColor(Theme.Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle {
                Text(subtitle)
                    .font(Theme.Font.body(15))
                    .foregroundColor(Theme.Palette.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct WelcomeStep: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("CARWISE")
                .font(.system(size: 48, weight: .black))
                .tracking(-1)
                .foregroundColor(Theme.Palette.ink)
            Text("A car advisor in your pocket.")
                .font(Theme.Font.headline(24))
                .foregroundColor(Theme.Palette.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 14) {
                benefitRow("Tell us what you need — we rank the cars that fit.",
                           icon: "target")
                benefitRow("Ask questions. Compare models side-by-side.",
                           icon: "bubble.left.and.bubble.right.fill")
                benefitRow("Stuck? Talk to a real consultant in minutes.",
                           icon: "person.fill.checkmark")
            }
            .padding(.top, 8)

            HStack(spacing: 10) {
                Rectangle().fill(Theme.Palette.accent).frame(width: 36, height: 4)
                Text("Takes under 90 seconds")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.Palette.inkSecondary)
            }
            .padding(.top, 12)

            Spacer(minLength: 80)
        }
    }

    private func benefitRow(_ text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.Palette.accent)
                .frame(width: 28, height: 28)
                .background(Theme.Palette.accentSoft)
                .clipShape(RoundedRectangle(cornerRadius: 7))
            Text(text)
                .font(Theme.Font.body(15))
                .foregroundColor(Theme.Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct BudgetStep: View {
    @Binding var profile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SectionTitle(
                eyebrow: "Step 1",
                title: "What's your budget?",
                subtitle: "Total out-the-door, before taxes. We'll never push you to overstretch."
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(profile.budgetSummary)
                    .font(Theme.Font.display(40))
                    .foregroundColor(Theme.Palette.accent)
                Text("\(Int(profile.budgetMin).formattedUSD) – \(Int(profile.budgetMax).formattedUSD)")
                    .font(Theme.Font.mono(13))
                    .foregroundColor(Theme.Palette.inkSecondary)
            }

            VStack(alignment: .leading, spacing: 16) {
                sliderGroup(label: "Minimum", value: $profile.budgetMin, range: 8_000...100_000)
                sliderGroup(label: "Maximum", value: $profile.budgetMax, range: 12_000...150_000)
            }
            .cardStyle(padding: 18)

            quickPresets
        }
    }

    private func sliderGroup(label: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .black)).tracking(1.2)
                    .foregroundColor(Theme.Palette.inkSecondary)
                Spacer()
                Text(Int(value.wrappedValue).formattedUSD)
                    .font(Theme.Font.mono(13))
                    .foregroundColor(Theme.Palette.ink)
            }
            Slider(value: value, in: range, step: 1_000)
                .tint(Theme.Palette.accent)
        }
    }

    private var quickPresets: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick presets")
                .font(.system(size: 11, weight: .black)).tracking(1.2)
                .foregroundColor(Theme.Palette.inkSecondary)
            FlowLayout(spacing: 8) {
                preset(label: "Under $25k", min: 15_000, max: 25_000)
                preset(label: "$25–$40k", min: 25_000, max: 40_000)
                preset(label: "$40–$60k", min: 40_000, max: 60_000)
                preset(label: "$60k+", min: 60_000, max: 100_000)
            }
        }
    }

    private func preset(label: String, min: Double, max: Double) -> some View {
        let isSelected = profile.budgetMin == min && profile.budgetMax == max
        return Chip(title: label, isSelected: isSelected) {
            profile.budgetMin = min
            profile.budgetMax = max
        }
    }
}

private struct VehicleTypeStep: View {
    @Binding var profile: UserProfile
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionTitle(
                eyebrow: "Step 2",
                title: "What type of car?",
                subtitle: "Pick as many as you're open to. Skip if you're undecided."
            )
            FlowLayout(spacing: 10) {
                ForEach(VehicleType.allCases) { type in
                    Chip(
                        title: type.displayName,
                        icon: type.systemImage,
                        isSelected: profile.vehicleTypes.contains(type)
                    ) {
                        vm.toggle(type)
                    }
                }
            }
        }
    }
}

private struct ConditionStep: View {
    @Binding var profile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionTitle(
                eyebrow: "Step 3",
                title: "New, used, or either?",
                subtitle: "Used typically stretches your budget further. New comes with warranty and latest tech."
            )
            VStack(spacing: 10) {
                ForEach(Condition.allCases) { c in
                    conditionRow(c)
                }
            }
        }
    }

    private func conditionRow(_ c: Condition) -> some View {
        Button {
            profile.condition = c
        } label: {
            HStack(spacing: 14) {
                Image(systemName: profile.condition == c ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(profile.condition == c ? Theme.Palette.accent : Theme.Palette.inkTertiary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(c.displayName)
                        .font(Theme.Font.title(16))
                        .foregroundColor(Theme.Palette.ink)
                    Text(blurb(for: c))
                        .font(Theme.Font.caption(12))
                        .foregroundColor(Theme.Palette.inkSecondary)
                }
                Spacer()
            }
            .padding(16)
            .background(profile.condition == c ? Theme.Palette.surfaceElevated : Theme.Palette.paper)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(profile.condition == c ? Theme.Palette.ink : Theme.Palette.border,
                            lineWidth: profile.condition == c ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func blurb(for c: Condition) -> String {
        switch c {
        case .new: return "Warranty, latest tech, faster depreciation."
        case .used: return "More car per dollar. Budget for inspection."
        case .either: return "Open to both — get the widest pool of options."
        }
    }
}

private struct UseCaseStep: View {
    @Binding var profile: UserProfile
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionTitle(
                eyebrow: "Step 4",
                title: "What will you use it for?",
                subtitle: "Pick everything that applies. Honest answers here matter most."
            )
            FlowLayout(spacing: 10) {
                ForEach(UseCase.allCases) { u in
                    Chip(
                        title: u.displayName,
                        icon: u.systemImage,
                        isSelected: profile.useCases.contains(u)
                    ) { vm.toggle(u) }
                }
            }
        }
    }
}

private struct FeatureStep: View {
    @Binding var profile: UserProfile
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionTitle(
                eyebrow: "Step 5",
                title: "What matters most?",
                subtitle: "Up to 3 things you care most about. These weigh heavily in ranking."
            )
            FlowLayout(spacing: 10) {
                ForEach(FeaturePriority.allCases) { f in
                    AccentChip(
                        title: f.displayName,
                        icon: f.systemImage,
                        isSelected: profile.featurePriorities.contains(f)
                    ) {
                        if profile.featurePriorities.contains(f) {
                            vm.toggle(f)
                        } else if profile.featurePriorities.count < 3 {
                            vm.toggle(f)
                        }
                    }
                }
            }
            Text("\(profile.featurePriorities.count) of 3 selected")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.Palette.inkSecondary)
        }
    }
}

private struct OwnershipStep: View {
    @Binding var profile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionTitle(
                eyebrow: "Step 6",
                title: "How long will you keep it?",
                subtitle: "Longer = we weight reliability more heavily when ranking."
            )
            VStack(spacing: 10) {
                ForEach(OwnershipLength.allCases) { l in
                    Button { profile.ownershipLength = l } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(l.displayName)
                                    .font(Theme.Font.title(16))
                                    .foregroundColor(Theme.Palette.ink)
                                Text(blurb(for: l))
                                    .font(Theme.Font.caption(12))
                                    .foregroundColor(Theme.Palette.inkSecondary)
                            }
                            Spacer()
                            Image(systemName: profile.ownershipLength == l ? "largecircle.fill.circle" : "circle")
                                .font(.system(size: 22))
                                .foregroundColor(profile.ownershipLength == l ? Theme.Palette.accent : Theme.Palette.inkTertiary)
                        }
                        .padding(16)
                        .background(profile.ownershipLength == l ? Theme.Palette.surfaceElevated : Theme.Palette.paper)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(profile.ownershipLength == l ? Theme.Palette.ink : Theme.Palette.border,
                                        lineWidth: profile.ownershipLength == l ? 1.5 : 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
    }

    private func blurb(for l: OwnershipLength) -> String {
        switch l {
        case .short: return "Lease-like timing. Depreciation matters."
        case .medium: return "Typical ownership span. Balanced weighting."
        case .long: return "Buy-and-hold. Reliability is king."
        }
    }
}

private struct BrandStep: View {
    @Binding var profile: UserProfile
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionTitle(
                eyebrow: "Step 7",
                title: "Any brand preferences?",
                subtitle: "Optional. We'll lightly prefer your picks — but still show strong off-brand matches."
            )
            FlowLayout(spacing: 10) {
                ForEach(MockCarDatabase.allBrands, id: \.self) { brand in
                    Chip(title: brand, isSelected: profile.preferredBrands.contains(brand)) {
                        vm.toggle(brand: brand)
                    }
                }
            }
        }
    }
}

private struct ReviewStep: View {
    let profile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            SectionTitle(
                eyebrow: "Ready",
                title: "Here's what we have",
                subtitle: "You can change any of this later from the Home tab."
            )

            VStack(alignment: .leading, spacing: 16) {
                reviewRow(label: "Budget", value: profile.budgetSummary, icon: "dollarsign.circle.fill")
                reviewRow(
                    label: "Vehicle type",
                    value: profile.vehicleTypes.isEmpty ? "Open to anything" :
                        profile.vehicleTypes.map { $0.displayName }.sorted().joined(separator: ", "),
                    icon: "car.fill"
                )
                reviewRow(label: "Condition", value: profile.condition.displayName, icon: "tag.fill")
                reviewRow(
                    label: "Use case",
                    value: profile.useCases.isEmpty ? "—" :
                        profile.useCases.map { $0.displayName }.sorted().joined(separator: ", "),
                    icon: "location.fill"
                )
                reviewRow(
                    label: "Priorities",
                    value: profile.featurePriorities.isEmpty ? "—" :
                        profile.featurePriorities.map { $0.displayName }.sorted().joined(separator: ", "),
                    icon: "star.fill"
                )
                reviewRow(label: "Ownership", value: profile.ownershipLength.displayName, icon: "hourglass")
                reviewRow(
                    label: "Brands",
                    value: profile.preferredBrands.isEmpty ? "No preference" :
                        profile.preferredBrands.sorted().joined(separator: ", "),
                    icon: "bookmark.fill"
                )
            }
            .cardStyle(padding: 18)
        }
    }

    private func reviewRow(label: String, value: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.Palette.accent)
                .frame(width: 26, height: 26)
                .background(Theme.Palette.accentSoft)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            VStack(alignment: .leading, spacing: 2) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .black)).tracking(1.2)
                    .foregroundColor(Theme.Palette.inkSecondary)
                Text(value)
                    .font(Theme.Font.body(14))
                    .foregroundColor(Theme.Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}

// MARK: - Helpers

private extension Int {
    var formattedUSD: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 0
        f.currencyCode = "USD"
        return f.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
}
