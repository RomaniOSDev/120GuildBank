import SwiftUI

struct AddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GuildBankViewModel
    private let editingMember: GuildMember?

    @State private var name: String = ""
    @State private var rank: String = "Member"
    @State private var class_: String = ""
    @State private var levelText: String = ""
    @State private var notes: String = ""
    @State private var isActive: Bool = true

    init(viewModel: GuildBankViewModel, editingMember: GuildMember? = nil) {
        self.viewModel = viewModel
        self.editingMember = editingMember

        _name = State(initialValue: editingMember?.name ?? "")
        _rank = State(initialValue: editingMember?.rank ?? "Member")
        _class_ = State(initialValue: editingMember?.class_ ?? "")
        _levelText = State(initialValue: editingMember?.level.map(String.init) ?? "")
        _notes = State(initialValue: editingMember?.notes ?? "")
        _isActive = State(initialValue: editingMember?.isActive ?? true)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile").foregroundColor(.gray)) {
                    TextField("Name", text: $name)

                    TextField("Rank", text: $rank)

                    TextField("Class (optional)", text: $class_)

                    TextField("Level (optional)", text: $levelText)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Notes").foregroundColor(.gray)) {
                    TextEditor(text: $notes)
                        .frame(height: 90)
                }

                Section {
                    Toggle("Active", isOn: $isActive)
                        .tint(.guildGold)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.guildDark)
            .tint(.guildGold)
            .listRowBackground(Color.guildDark.opacity(0.75))
            .environment(\.colorScheme, .dark)
            .navigationTitle(editingMember == nil ? "New member" : "Edit member")
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

        let level = Int(levelText.trimmingCharacters(in: .whitespacesAndNewlines))
        let trimmedClass = class_.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        let member = GuildMember(
            id: editingMember?.id ?? UUID(),
            name: trimmedName,
            rank: rank.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Member" : rank.trimmingCharacters(in: .whitespacesAndNewlines),
            class_: trimmedClass.isEmpty ? nil : trimmedClass,
            level: level,
            joinedDate: editingMember?.joinedDate ?? Date(),
            totalDonations: editingMember?.totalDonations ?? 0,
            totalWithdrawals: editingMember?.totalWithdrawals ?? 0,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
            isActive: isActive,
            createdAt: editingMember?.createdAt ?? Date()
        )

        if editingMember == nil {
            viewModel.addMember(member)
        } else {
            viewModel.updateMember(member)
        }
        dismiss()
    }
}

