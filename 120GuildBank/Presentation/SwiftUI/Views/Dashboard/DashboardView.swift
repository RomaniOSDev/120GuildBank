import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: GuildBankViewModel
    @State private var isPresentingAddTransaction = false
    @State private var selectedTransaction: Transaction?
    @State private var showOnlyFavorites = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.guildScreenBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header

                        quickActions

                        statsStrip

                        goalsPreviewSection

                        lowStockSection

                        topDonorsSection

                        recentTransactionsSection
                    }
                    .padding(.vertical, 14)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddTransaction = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.guildGold)
                            .font(.title2)
                    }
                    .accessibilityLabel("Add transaction")
                }
            }
        }
        .sheet(isPresented: $isPresentingAddTransaction) {
            AddTransactionView(viewModel: viewModel)
        }
        .sheet(item: $selectedTransaction) { transaction in
            AddTransactionView(viewModel: viewModel, editingTransaction: transaction)
        }
    }

    private var header: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [Color.guildGold.opacity(0.18), Color.guildGreen.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.guildGold.opacity(0.35), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 8) {
                Label("Home", systemImage: "shield.lefthalf.filled")
                    .font(.title2.bold())
                    .foregroundColor(.guildGold)

                Text("Track treasury, monitor goals, and react to low stock fast.")
                    .foregroundColor(.white.opacity(0.9))
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    Label("\(viewModel.members.count) members", systemImage: "person.3.fill")
                        .foregroundColor(.guildGreen)
                    Label("\(viewModel.transactions.count) records", systemImage: "list.bullet.rectangle")
                        .foregroundColor(.guildGold)
                }
                .font(.caption.bold())
            }
            .padding()
        }
        .padding(.horizontal)
    }

    private var quickActions: some View {
        HStack(spacing: 10) {
            Button {
                isPresentingAddTransaction = true
            } label: {
                Label("New transaction", systemImage: "plus.circle.fill")
                    .font(.subheadline.bold())
                    .guildGradientButton(start: .guildGold, end: .guildGreen)
            }

            Button {
                showOnlyFavorites.toggle()
            } label: {
                Label(showOnlyFavorites ? "Favorites on" : "Favorites off", systemImage: showOnlyFavorites ? "star.fill" : "star")
                    .font(.subheadline.bold())
                    .guildGradientButton(start: .guildGreen, end: .guildGold)
            }
        }
        .padding(.horizontal)
    }

    private var statsStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Total gold",
                    value: "\(viewModel.totalGold) 🪙",
                    icon: "crown.fill",
                    color: .guildGold,
                    cardColor: .guildGold.opacity(0.1)
                )

                StatCard(
                    title: "Donations",
                    value: "\(viewModel.totalDonations) 🪙",
                    icon: "arrow.up.circle.fill",
                    color: .guildGreen,
                    cardColor: .guildGold.opacity(0.1)
                )

                StatCard(
                    title: "Spending",
                    value: "\(viewModel.totalWithdrawals) 🪙",
                    icon: "arrow.down.circle.fill",
                    color: .guildGold,
                    cardColor: .guildGold.opacity(0.1)
                )

                StatCard(
                    title: "Members",
                    value: "\(viewModel.members.count)",
                    icon: "person.3.fill",
                    color: .guildGreen,
                    cardColor: .guildGold.opacity(0.1)
                )
            }
            .padding(.horizontal)
        }
    }

    private var goalsPreviewSection: some View {
        let activeGoals = viewModel.goals.filter { !$0.isCompleted }.prefix(2)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Active goals")
                .font(.headline)
                .foregroundColor(.guildGold)
                .padding(.horizontal)

            if activeGoals.isEmpty {
                sectionEmptyState("No active goals yet.")
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(activeGoals), id: \.id) { goal in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(goal.name)
                                    .foregroundColor(.white)
                                    .font(.subheadline.bold())
                                    .lineLimit(1)
                                Spacer()
                                Text("\(Int(goal.progress * 100))%")
                                    .foregroundColor(.guildGreen)
                                    .font(.caption.bold())
                            }
                            ProgressView(value: goal.progress)
                                .tint(.guildGold)
                        }
                        .padding()
                        .background(Color.guildGold.opacity(0.08))
                        .guildCard(border: .guildGold)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var lowStockSection: some View {
        let lowStock = viewModel.resources.filter { $0.quantity <= $0.minStock }.prefix(3)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Low stock alerts")
                .font(.headline)
                .foregroundColor(.guildGold)
                .padding(.horizontal)

            if lowStock.isEmpty {
                sectionEmptyState("All resources are above minimum stock.")
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(lowStock), id: \.id) { resource in
                        HStack {
                            Label(resource.name, systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.guildGold)
                                .lineLimit(1)
                            Spacer()
                            Text("\(resource.quantity) / min \(resource.minStock)")
                                .foregroundColor(.white)
                                .font(.caption.bold())
                        }
                        .padding(12)
                        .background(Color.guildGold.opacity(0.08))
                        .guildCard(border: .guildGold)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var topDonorsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Top donors")
                .font(.headline)
                .foregroundColor(.guildGold)
                .padding(.horizontal)

            if viewModel.topDonors.isEmpty {
                Text("No donation data yet.")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.topDonors.prefix(5)) { donor in
                        HStack {
                            Text(donor.name)
                                .foregroundColor(.white)

                            Spacer()

                            Text("+\(donor.amount) 🪙")
                                .foregroundColor(.guildGreen)
                                .bold()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                }
                .padding(.vertical, 10)
                .background(Color.guildGold.opacity(0.05))
                .guildCard(border: .guildGold)
                .padding(.horizontal)
            }
        }
    }

    private var recentTransactionsSection: some View {
        let transactions = showOnlyFavorites
            ? viewModel.recentTransactions.filter { $0.isFavorite }
            : viewModel.recentTransactions

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent transactions")
                    .font(.headline)
                    .foregroundColor(.guildGold)

                Spacer()

                if showOnlyFavorites {
                    Text("Favorites")
                        .font(.caption.bold())
                        .foregroundColor(.guildGreen)
                }
            }
            .padding(.horizontal)

            if transactions.isEmpty {
                sectionEmptyState(showOnlyFavorites ? "No favorite transactions yet." : "No transactions yet.")
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction)
                            .onTapGesture {
                                selectedTransaction = transaction
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deleteTransaction(transaction)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func sectionEmptyState(_ message: String) -> some View {
        Text(message)
            .foregroundColor(.gray)
            .padding(.horizontal)
            .padding(.vertical, 8)
    }
}

