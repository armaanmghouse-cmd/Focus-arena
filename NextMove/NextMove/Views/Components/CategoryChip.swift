import SwiftUI

struct CategoryChip: View {
    let category: GoalCategory
    var selected: Bool = true

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: category.symbol)
                .font(.system(size: 11, weight: .semibold))
            Text(category.label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .foregroundStyle(selected ? Color.white : category.color)
        .background(
            Capsule().fill(selected ? category.color : category.color.opacity(0.12))
        )
    }
}
