import SwiftUI

struct GoalCard: View {
    let goal: GuildGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(goal.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if goal.isCompleted {
                    Text("Completed")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.guildGreen.opacity(0.2))
                        .foregroundColor(.guildGreen)
                        .cornerRadius(8)
                }
            }

            HStack(spacing: 10) {
                Text("Progress:")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(goal.currentAmount)/\(goal.targetAmount) 🪙")
                    .font(.caption)
                    .foregroundColor(.guildGold)

                Spacer()

                ProgressView(value: goal.progress)
                    .tint(.guildGold)
                    .frame(width: 110, height: 4)
            }

            if let deadline = goal.deadline {
                Text("Due \(formattedShortDate(deadline))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.guildGold.opacity(0.06))
        .guildCard(border: goal.isCompleted ? .guildGreen : .guildGold)
    }
}

