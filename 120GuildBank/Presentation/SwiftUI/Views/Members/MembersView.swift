import SwiftUI

struct MembersView: View {
    @ObservedObject var viewModel: GuildBankViewModel
    @State private var isPresentingAddMember = false
    @State private var selectedMember: GuildMember?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.guildScreenBackground()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.members) { member in
                            MemberCard(member: member)
                                .onTapGesture {
                                    selectedMember = member
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.deleteMember(member)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        viewModel.toggleActive(member)
                                    } label: {
                                        Label(member.isActive ? "Deactivate" : "Activate", systemImage: "power")
                                    }
                                    .tint(.guildGold)
                                }
                        }

                        Button {
                            isPresentingAddMember = true
                        } label: {
                            Text("Add member")
                                .font(.headline)
                                .guildGradientButton(start: .guildGold, end: .guildGreen)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Members")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isPresentingAddMember) {
            AddMemberView(viewModel: viewModel)
        }
        .sheet(item: $selectedMember) { member in
            AddMemberView(viewModel: viewModel, editingMember: member)
        }
    }
}

