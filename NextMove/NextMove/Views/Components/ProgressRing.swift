import SwiftUI

struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 12
    var size: CGFloat = 120
    var gradient: LinearGradient = Theme.accentGradient

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.surfaceElevated, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(
                    gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.6), value: progress)
        }
        .frame(width: size, height: size)
    }
}
