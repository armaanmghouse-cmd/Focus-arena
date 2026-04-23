import SwiftUI

struct CompareView: View {
    let cars: [Car]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                VStack(spacing: 0) {
                    gridHeader
                    Divider()
                    compareRow(label: "Price", values: cars.map { $0.priceDisplay })
                    compareRow(label: "Years", values: cars.map { $0.yearRange })
                    compareRow(label: "MPG", values: cars.map { $0.mpgDisplay })
                    compareRow(label: "Horsepower", values: cars.map { "\($0.horsepower) hp" })
                    compareRow(label: "Seats", values: cars.map { "\($0.seatingCapacity)" })
                    compareRow(label: "Cargo", values: cars.map { String(format: "%.1f ft³", $0.cargoCubicFeet) })
                    compareRow(label: "Drivetrain", values: cars.map { $0.drivetrain })
                    compareRow(label: "Transmission", values: cars.map { $0.transmission })
                }
                .cardStyle(padding: 0)

                scoreGrid

                takeaways
            }
            .padding(16)
        }
        .background(Theme.Palette.surface.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("COMPARE")
                    .font(.system(size: 12, weight: .black)).tracking(2.5)
                    .foregroundColor(Theme.Palette.ink)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SIDE BY SIDE")
                .font(.system(size: 11, weight: .black)).tracking(1.8)
                .foregroundColor(Theme.Palette.accent)
            Text("\(cars.count) cars")
                .font(Theme.Font.display(28))
                .foregroundColor(Theme.Palette.ink)
        }
    }

    private var gridHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            headerCell("")
            ForEach(cars) { car in
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: car.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Theme.Palette.ink)
                    Text(car.displayName)
                        .font(Theme.Font.title(13))
                        .foregroundColor(Theme.Palette.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                    Text(car.type.displayName.uppercased())
                        .font(.system(size: 9, weight: .black)).tracking(0.8)
                        .foregroundColor(Theme.Palette.accent)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Palette.surface)
            }
        }
    }

    private func headerCell(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .black)).tracking(1.2)
            .foregroundColor(Theme.Palette.inkTertiary)
            .frame(width: 90, alignment: .leading)
            .padding(12)
    }

    private func compareRow(label: String, values: [String]) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .black)).tracking(1.1)
                .foregroundColor(Theme.Palette.inkSecondary)
                .frame(width: 90, alignment: .leading)
                .padding(.vertical, 12).padding(.leading, 12)
            ForEach(Array(values.enumerated()), id: \.offset) { _, v in
                Text(v)
                    .font(Theme.Font.mono(13))
                    .foregroundColor(Theme.Palette.ink)
                    .padding(.vertical, 12).padding(.horizontal, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(Theme.Palette.border),
            alignment: .top
        )
    }

    // MARK: - Scores grid

    private var scoreGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Characteristic scores").font(Theme.Font.headline(18)).foregroundColor(Theme.Palette.ink)
            VStack(spacing: 10) {
                scoreRow(label: "Reliability", values: cars.map { $0.reliabilityScore })
                scoreRow(label: "Fuel economy", values: cars.map { $0.fuelEconomyScore })
                scoreRow(label: "Tech", values: cars.map { $0.techScore })
                scoreRow(label: "Luxury", values: cars.map { $0.luxuryScore })
                scoreRow(label: "Safety", values: cars.map { $0.safetyScore })
                scoreRow(label: "Performance", values: cars.map { $0.performanceScore })
                scoreRow(label: "Cargo", values: cars.map { $0.cargoScore })
            }
        }
        .cardStyle(padding: 16)
    }

    private func scoreRow(label: String, values: [Int]) -> some View {
        let best = values.max() ?? 0
        return HStack(alignment: .center, spacing: 10) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .black)).tracking(1.1)
                .foregroundColor(Theme.Palette.inkSecondary)
                .frame(width: 92, alignment: .leading)
            HStack(spacing: 6) {
                ForEach(Array(values.enumerated()), id: \.offset) { _, v in
                    HStack(spacing: 0) {
                        Text("\(v)")
                            .font(Theme.Font.mono(13))
                            .foregroundColor(v == best ? .white : Theme.Palette.ink)
                            .padding(.vertical, 4).padding(.horizontal, 8)
                            .background(v == best ? Theme.Palette.accent : Theme.Palette.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Takeaways

    private var takeaways: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Takeaways").font(Theme.Font.headline(18)).foregroundColor(Theme.Palette.ink)

            if let cheapest = cars.min(by: { $0.priceMin < $1.priceMin }) {
                takeawayRow(icon: "dollarsign.circle.fill", tag: "CHEAPEST", car: cheapest,
                            blurb: "Lowest entry price of the group.")
            }
            if let mostReliable = cars.max(by: { $0.reliabilityScore < $1.reliabilityScore }) {
                takeawayRow(icon: "checkmark.shield.fill", tag: "MOST RELIABLE", car: mostReliable,
                            blurb: "Highest reliability score — long-term safe pick.")
            }
            if let mostEfficient = cars.max(by: { ($0.mpgCity + $0.mpgHighway) < ($1.mpgCity + $1.mpgHighway) }) {
                takeawayRow(icon: "fuelpump.fill", tag: "MOST EFFICIENT", car: mostEfficient,
                            blurb: "Best combined fuel economy of the group.")
            }
            if let sportiest = cars.max(by: { $0.performanceScore < $1.performanceScore }) {
                takeawayRow(icon: "flame.fill", tag: "SPORTIEST", car: sportiest,
                            blurb: "Highest performance score.")
            }
        }
        .cardStyle(padding: 16)
    }

    private func takeawayRow(icon: String, tag: String, car: Car, blurb: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Theme.Palette.accent)
                .clipShape(RoundedRectangle(cornerRadius: 7))
            VStack(alignment: .leading, spacing: 2) {
                Text(tag).font(.system(size: 10, weight: .black)).tracking(1.2)
                    .foregroundColor(Theme.Palette.accent)
                Text(car.displayName).font(Theme.Font.title(15)).foregroundColor(Theme.Palette.ink)
                Text(blurb).font(Theme.Font.caption(12)).foregroundColor(Theme.Palette.inkSecondary)
            }
            Spacer()
        }
    }
}
