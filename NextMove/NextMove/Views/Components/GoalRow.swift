import SwiftUI

struct GoalRow: View {
    let goal: Goal
    let onToggle: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(goal.isCompleted ? Theme.success : Theme.textMuted)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(goal.title)
                        .font(.nmBody.weight(.semibold))
                        .foregroundStyle(goal.isCompleted ? Theme.textMuted : Theme.textPrimary)
                        .strikethrough(goal.isCompleted, color: Theme.textMuted)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 6) {
                        PriorityBadge(priority: goal.priority, compact: true)
                        CategoryChip(category: goal.category, selected: false)
                        if let deadline = goal.deadline {
                            HStack(spacing: 3) {
                                Image(systemName: "clock")
                                    .font(.system(size: 9, weight: .semibold))
                                Text(deadline, style: .time)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                            }
                            .foregroundStyle(goal.isOverdue ? Theme.danger : Theme.textSecondary)
                        }
                        if goal.period == .midday {
                            Text("MIDDAY")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.accentSecondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(Theme.accentSecondary.opacity(0.12))
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    goal.isOverdue ? Theme.danger.opacity(0.4) : Theme.divider.opacity(0.3),
                    lineWidth: 0.5
                )
        )
    }
}
