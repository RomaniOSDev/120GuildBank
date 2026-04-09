import SwiftUI

struct GoalsView: View {
    @ObservedObject var viewModel: GuildBankViewModel
    @State private var isPresentingAddGoal = false
    @State private var selectedGoal: GuildGoal?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.guildScreenBackground()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.goals) { goal in
                            GoalCard(goal: goal)
                                .onTapGesture {
                                    selectedGoal = goal
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.deleteGoal(goal)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    if !goal.isCompleted {
                                        Button {
                                            viewModel.completeGoal(goal)
                                        } label: {
                                            Label("Complete", systemImage: "checkmark")
                                        }
                                        .tint(.guildGreen)
                                    }
                                }
                        }

                        Button {
                            isPresentingAddGoal = true
                        } label: {
                            Text("Add goal")
                                .font(.headline)
                                .guildGradientButton(start: .guildGold, end: .guildGreen)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isPresentingAddGoal) {
            AddGoalView(viewModel: viewModel)
        }
        .sheet(item: $selectedGoal) { goal in
            AddGoalView(viewModel: viewModel, editingGoal: goal)
        }
    }
}

