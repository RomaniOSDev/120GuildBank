import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GuildBankViewModel
    private let editingTransaction: Transaction?

    @State private var type: TransactionType = .donation
    @State private var currency: CurrencyType = .gold
    @State private var amount: Int = 0

    @State private var selectedMemberId: UUID? = nil
    @State private var newMemberName: String = ""

    @State private var description: String = ""
    @State private var relatedItem: String = ""
    @State private var quantity: Int = 1
    @State private var approvedBy: String = ""
    @State private var notes: String = ""
    @State private var isFavorite: Bool = false

    init(viewModel: GuildBankViewModel, editingTransaction: Transaction? = nil) {
        self.viewModel = viewModel
        self.editingTransaction = editingTransaction

        _type = State(initialValue: editingTransaction?.type ?? .donation)
        _currency = State(initialValue: editingTransaction?.currency ?? .gold)
        _amount = State(initialValue: editingTransaction?.amount ?? 0)
        _selectedMemberId = State(initialValue: editingTransaction?.memberId)
        _newMemberName = State(initialValue: editingTransaction?.memberName ?? "")
        _description = State(initialValue: editingTransaction?.description ?? "")
        _relatedItem = State(initialValue: editingTransaction?.relatedItem ?? "")
        _quantity = State(initialValue: editingTransaction?.quantity ?? 1)
        _approvedBy = State(initialValue: editingTransaction?.approvedBy ?? "")
        _notes = State(initialValue: editingTransaction?.notes ?? "")
        _isFavorite = State(initialValue: editingTransaction?.isFavorite ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $type) {
                        ForEach(TransactionType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }

                    Picker("Currency", selection: $currency) {
                        ForEach(CurrencyType.allCases) { currency in
                            Label(currency.rawValue, systemImage: currency.icon).tag(currency)
                        }
                    }

                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0", value: $amount, format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 110)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section(header: Text("Member").foregroundColor(.gray)) {
                    Picker("Member", selection: $selectedMemberId) {
                        Text("—").tag(nil as UUID?)
                        ForEach(viewModel.members) { member in
                            Text(member.name).tag(member.id as UUID?)
                        }
                    }

                    if selectedMemberId == nil {
                        TextField("Member name", text: $newMemberName)
                    }
                }

                Section(header: Text("Details").foregroundColor(.gray)) {
                    TextField("Description", text: $description)
                    TextField("Item / resource", text: $relatedItem)

                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...999)

                    TextField("Approved by", text: $approvedBy)
                }

                Section(header: Text("Notes").foregroundColor(.gray)) {
                    TextEditor(text: $notes)
                        .frame(height: 90)
                }

                Section {
                    Toggle("Add to favorites", isOn: $isFavorite)
                        .tint(.guildGold)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.guildDark)
            .tint(.guildGold)
            .listRowBackground(Color.guildDark.opacity(0.75))
            .environment(\.colorScheme, .dark)
            .navigationTitle(editingTransaction == nil ? "New transaction" : "Edit transaction")
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
                        .disabled(!canSave)
                }
            }
        }
        .presentationBackground(Color.guildDark)
    }

    private var canSave: Bool {
        amount > 0 && (!description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    private func save() {
        let resolvedMember: (id: UUID?, name: String?) = {
            if let id = selectedMemberId, let member = viewModel.members.first(where: { $0.id == id }) {
                return (id: member.id, name: member.name)
            }
            let name = newMemberName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { return (id: nil, name: nil) }
            let member = GuildMember(
                id: UUID(),
                name: name,
                rank: "Member",
                class_: nil,
                level: nil,
                joinedDate: Date(),
                totalDonations: 0,
                totalWithdrawals: 0,
                notes: nil,
                isActive: true,
                createdAt: Date()
            )
            viewModel.addMember(member)
            return (id: member.id, name: member.name)
        }()

        let tx = Transaction(
            id: editingTransaction?.id ?? UUID(),
            date: editingTransaction?.date ?? Date(),
            type: type,
            currency: currency,
            amount: amount,
            memberId: resolvedMember.id,
            memberName: resolvedMember.name,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            relatedItem: relatedItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : relatedItem.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: quantity,
            approvedBy: approvedBy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : approvedBy.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines),
            isFavorite: isFavorite,
            createdAt: editingTransaction?.createdAt ?? Date()
        )

        if editingTransaction == nil {
            viewModel.addTransaction(tx)
        } else {
            viewModel.updateTransaction(tx)
        }
        dismiss()
    }
}

