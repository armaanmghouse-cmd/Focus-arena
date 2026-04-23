import SwiftUI

/// Circular score indicator (0–100). Red when ≥80, ink otherwise. Bold editorial feel.
struct ScoreRing: View {
    let score: Int
    var label: String = "MATCH"
    var size: CGFloat = 72

    private var normalized: Double { Double(max(0, min(score, 100))) / 100.0 }
    private var color: Color {
        score >= 80 ? Theme.Palette.accent : Theme.Palette.ink
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.Palette.border, lineWidth: size * 0.10)
            Circle()
                .trim(from: 0, to: normalized)
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.6), value: normalized)
            VStack(spacing: 0) {
                Text("\(score)")
                    .font(.system(size: size * 0.32, weight: .black))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: size * 0.13, weight: .black))
                    .tracking(1.0)
                    .foregroundColor(Theme.Palette.inkTertiary)
            }
        }
        .frame(width: size, height: size)
    }
}

struct ScoreBar: View {
    let label: String
    let score: Int       // 0–10
    var color: Color = Theme.Palette.ink

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .black))
                    .tracking(0.7)
                    .foregroundColor(Theme.Palette.inkSecondary)
                Spacer()
                Text("\(score)/10")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.Palette.ink)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Theme.Palette.border)
                        .frame(height: 4)
                    Rectangle()
                        .fill(color)
                        .frame(width: geo.size.width * (CGFloat(score) / 10.0), height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}
