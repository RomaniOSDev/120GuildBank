import SwiftUI

struct ResourcesView: View {
    @ObservedObject var viewModel: GuildBankViewModel

    @State private var isPresentingAddResource = false

    @State private var isPresentingAdjust = false
    @State private var adjustMode: AdjustMode = .add
    @State private var adjustAmountText: String = "1"
    @State private var selectedResource: Resource? = nil
    @State private var editingResource: Resource? = nil

    private enum AdjustMode {
        case add, remove

        var title: String {
            switch self {
            case .add: return "Add quantity"
            case .remove: return "Remove quantity"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.guildScreenBackground()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.resources) { resource in
                            ResourceCard(resource: resource)
                                .onTapGesture {
                                    editingResource = resource
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.deleteResource(resource)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        selectedResource = resource
                                        adjustMode = .add
                                        adjustAmountText = "1"
                                        isPresentingAdjust = true
                                    } label: {
                                        Label("Restock", systemImage: "plus")
                                    }
                                    .tint(.guildGreen)

                                    Button {
                                        selectedResource = resource
                                        adjustMode = .remove
                                        adjustAmountText = "1"
                                        isPresentingAdjust = true
                                    } label: {
                                        Label("Issue", systemImage: "minus")
                                    }
                                    .tint(.guildGold)
                                }
                        }

                        Button {
                            isPresentingAddResource = true
                        } label: {
                            Text("Add resource")
                                .font(.headline)
                                .guildGradientButton(start: .guildGreen, end: .guildGold)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Resources")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isPresentingAddResource) {
            AddResourceView(viewModel: viewModel)
        }
        .sheet(item: $editingResource) { resource in
            AddResourceView(viewModel: viewModel, editingResource: resource)
        }
        .alert(adjustMode.title, isPresented: $isPresentingAdjust) {
            TextField("Amount", text: $adjustAmountText)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) {}
            Button("Apply") { applyAdjust() }
        } message: {
            Text(selectedResource?.name ?? "")
        }
    }

    private func applyAdjust() {
        guard let resource = selectedResource else { return }
        let amount = Int(adjustAmountText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        guard amount > 0 else { return }

        switch adjustMode {
        case .add:
            viewModel.addResourceQuantity(resource, amount: amount)
        case .remove:
            viewModel.removeResourceQuantity(resource, amount: amount)
        }
    }
}

