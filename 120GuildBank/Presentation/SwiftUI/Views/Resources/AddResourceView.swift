import SwiftUI

struct AddResourceView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GuildBankViewModel
    private let editingResource: Resource?

    @State private var name: String = ""
    @State private var type: ResourceType = .materials
    @State private var quantityText: String = "1"
    @State private var minStockText: String = "0"
    @State private var location: String = ""
    @State private var notes: String = ""

    init(viewModel: GuildBankViewModel, editingResource: Resource? = nil) {
        self.viewModel = viewModel
        self.editingResource = editingResource

        _name = State(initialValue: editingResource?.name ?? "")
        _type = State(initialValue: editingResource?.type ?? .materials)
        _quantityText = State(initialValue: editingResource.map { String($0.quantity) } ?? "1")
        _minStockText = State(initialValue: editingResource.map { String($0.minStock) } ?? "0")
        _location = State(initialValue: editingResource?.location ?? "")
        _notes = State(initialValue: editingResource?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Resource").foregroundColor(.gray)) {
                    TextField("Name", text: $name)

                    Picker("Type", selection: $type) {
                        ForEach(ResourceType.allCases) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }

                    TextField("Quantity", text: $quantityText)
                        .keyboardType(.numberPad)

                    TextField("Minimum stock", text: $minStockText)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Details").foregroundColor(.gray)) {
                    TextField("Location (optional)", text: $location)
                    TextEditor(text: $notes)
                        .frame(height: 90)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.guildDark)
            .tint(.guildGold)
            .listRowBackground(Color.guildDark.opacity(0.75))
            .environment(\.colorScheme, .dark)
            .navigationTitle(editingResource == nil ? "New resource" : "Edit resource")
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

        let quantity = Int(quantityText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let minStock = Int(minStockText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        let resource = Resource(
            id: editingResource?.id ?? UUID(),
            name: trimmedName,
            type: type,
            quantity: max(0, quantity),
            minStock: max(0, minStock),
            location: trimmedLocation.isEmpty ? nil : trimmedLocation,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
            lastUpdated: Date()
        )

        if editingResource == nil {
            viewModel.addResource(resource)
        } else {
            viewModel.updateResource(resource)
        }
        dismiss()
    }
}

