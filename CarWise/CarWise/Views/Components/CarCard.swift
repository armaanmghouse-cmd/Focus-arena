import SwiftUI

/// Big editorial card — the primary unit on the Recommendations tab.
struct CarCard: View {
    let recommendation: Recommendation
    var isSaved: Bool
    var isInCompare: Bool
    var onTap: () -> Void
    var onSave: () -> Void
    var onToggleCompare: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                header
                body_
                footer
            }
            .background(Theme.Palette.paper)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius, style: .continuous)
                    .stroke(Theme.Palette.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    RedPill(text: recommendation.car.type.displayName)
                    if recommendation.bestValueScore >= 80 {
                        InkPill(text: "Best value")
                    }
                }
                Text(recommendation.car.displayName)
                    .font(Theme.Font.headline(22))
                    .foregroundColor(Theme.Palette.ink)
                    .lineLimit(1)
                Text(recommendation.car.yearRange + " · " + recommendation.car.priceDisplay)
                    .font(Theme.Font.caption(12))
                    .foregroundColor(Theme.Palette.inkSecondary)
            }
            Spacer()
            ScoreRing(score: recommendation.matchScore, label: "MATCH", size: 66)
        }
        .padding(16)
    }

    private var body_: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 18) {
                specStat(value: recommendation.car.mpgDisplay, label: "MPG")
                specStat(value: "\(recommendation.car.horsepower)", label: "HP")
                specStat(value: recommendation.car.drivetrain, label: "DRIVE")
            }
            FlowLayout(spacing: 6) {
                ForEach(recommendation.matchHighlights, id: \.self) { h in
                    Text(h)
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.3)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.Palette.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Theme.Palette.border, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .foregroundColor(Theme.Palette.ink)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }

    private var footer: some View {
        HStack(spacing: 0) {
            Button(action: onSave) {
                HStack(spacing: 6) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 13, weight: .bold))
                    Text(isSaved ? "Saved" : "Save")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(isSaved ? Theme.Palette.accent : Theme.Palette.ink)
                .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(PressableButtonStyle())
            Divider().frame(height: 44)
            Button(action: onToggleCompare) {
                HStack(spacing: 6) {
                    Image(systemName: isInCompare ? "checkmark.square.fill" : "square.on.square")
                        .font(.system(size: 13, weight: .bold))
                    Text(isInCompare ? "In compare" : "Compare")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(isInCompare ? Theme.Palette.accent : Theme.Palette.ink)
                .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(PressableButtonStyle())
        }
        .background(Theme.Palette.surface)
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(Theme.Palette.border),
            alignment: .top
        )
    }

    private func specStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(Theme.Font.mono(14))
                .foregroundColor(Theme.Palette.ink)
            Text(label)
                .font(.system(size: 9, weight: .black))
                .tracking(0.9)
                .foregroundColor(Theme.Palette.inkTertiary)
        }
    }
}

/// Compact card — used in Home and Saved.
struct CompactCarCard: View {
    let car: Car
    var matchScore: Int? = nil
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.Palette.surface)
                    Image(systemName: car.symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Theme.Palette.ink)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 3) {
                    Text(car.displayName)
                        .font(Theme.Font.title(15))
                        .foregroundColor(Theme.Palette.ink)
                    Text(car.priceDisplay + " · " + car.yearRange)
                        .font(Theme.Font.caption(11))
                        .foregroundColor(Theme.Palette.inkSecondary)
                }
                Spacer()
                if let score = matchScore {
                    Text("\(score)")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(score >= 80 ? Theme.Palette.accent : Theme.Palette.ink)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.Palette.inkTertiary)
            }
            .padding(12)
            .background(Theme.Palette.paper)
            .overlay(
                RoundedRectangle(cornerRadius: 12).stroke(Theme.Palette.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PressableButtonStyle())
    }
}
