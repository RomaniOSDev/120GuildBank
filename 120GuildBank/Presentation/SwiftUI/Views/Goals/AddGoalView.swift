import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GuildBankViewModel
    private let editingGoal: GuildGoal?

    @State private var name: String = ""
    @State private var targetText: String = "0"
    @State private var currentText: String = "0"
    @State private var currency: CurrencyType = .gold
    @State private var hasDeadline: Bool = false
    @State private var deadline: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var notes: String = ""

    init(viewModel: GuildBankViewModel, editingGoal: GuildGoal? = nil) {
        self.viewModel = viewModel
        self.editingGoal = editingGoal

        _name = State(initialValue: editingGoal?.name ?? "")
        _targetText = State(initialValue: editingGoal.map { String($0.targetAmount) } ?? "0")
        _currentText = State(initialValue: editingGoal.map { String($0.currentAmount) } ?? "0")
        _currency = State(initialValue: editingGoal?.currency ?? .gold)
        _hasDeadline = State(initialValue: editingGoal?.deadline != nil)
        _deadline = State(initialValue: editingGoal?.deadline ?? (Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()))
        _notes = State(initialValue: editingGoal?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Goal").foregroundColor(.gray)) {
                    TextField("Name", text: $name)

                    Picker("Currency", selection: $currency) {
                        ForEach(CurrencyType.allCases) { c in
                            Label(c.rawValue, systemImage: c.icon).tag(c)
                        }
                    }

                    TextField("Target amount", text: $targetText)
                        .keyboardType(.numberPad)

                    TextField("Current amount", text: $currentText)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Deadline").foregroundColor(.gray)) {
                    Toggle("Set a deadline", isOn: $hasDeadline)
                        .tint(.guildGold)

                    if hasDeadline {
                        DatePicker("Date", selection: $deadline, displayedComponents: .date)
                    }
                }

                Section(header: Text("Notes").foregroundColor(.gray)) {
                    TextEditor(text: $notes)
                        .frame(height: 90)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.guildDark)
            .tint(.guildGold)
            .listRowBackground(Color.guildDark.opacity(0.75))
            .environment(\.colorScheme, .dark)
            .navigationTitle(editingGoal == nil ? "New goal" : "Edit goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.guildGold)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundColor(.guildGold)
                        .bold()
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationBackground(Color.guildDark)
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let target = Int(targetText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let current = Int(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        let goal = GuildGoal(
            id: editingGoal?.id ?? UUID(),
            name: trimmedName,
            targetAmount: max(0, target),
            currentAmount: max(0, current),
            currency: currency,
            deadline: hasDeadline ? deadline : nil,
            isCompleted: max(0, current) >= max(0, target) && target > 0,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
            createdAt: editingGoal?.createdAt ?? Date()
        )

        if editingGoal == nil {
            viewModel.addGoal(goal)
        } else {
            viewModel.updateGoal(goal)
        }
        dismiss()
    }
}

