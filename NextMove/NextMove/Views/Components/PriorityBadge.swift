import SwiftUI

struct PriorityBadge: View {
    let priority: GoalPriority
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: priority.symbol)
                .font(.system(size: compact ? 9 : 11, weight: .bold))
            Text(priority.label.uppercased())
                .font(.system(size: compact ? 10 : 11, weight: .bold, design: .rounded))
        }
        .padding(.horizontal, compact ? 6 : 8)
        .padding(.vertical, compact ? 3 : 4)
        .foregroundStyle(priority.color)
        .background(
            Capsule().fill(priority.color.opacity(0.12))
        )
        .overlay(
            Capsule().strokeBorder(priority.color.opacity(0.4), lineWidth: 0.5)
        )
    }
}
