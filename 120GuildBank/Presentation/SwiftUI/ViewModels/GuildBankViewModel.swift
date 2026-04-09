import Foundation
import Combine
import SwiftUI

final class GuildBankViewModel: ObservableObject {
    // MARK: - Published
    @Published var members: [GuildMember] = []
    @Published var transactions: [Transaction] = []
    @Published var resources: [Resource] = []
    @Published var goals: [GuildGoal] = []

    // MARK: - Derived
    var totalGold: Int {
        transactions.reduce(0) { result, transaction in
            if transaction.type == .donation { return result + transaction.amount }
            return result - transaction.amount
        }
    }

    var totalDonations: Int {
        transactions.filter { $0.type == .donation }.reduce(0) { $0 + $1.amount }
    }

    var totalWithdrawals: Int {
        transactions.filter { $0.type != .donation }.reduce(0) { $0 + $1.amount }
    }

    var monthlyIncome: Int {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        return transactions.filter {
            $0.type == .donation &&
            calendar.component(.month, from: $0.date) == currentMonth &&
            calendar.component(.year, from: $0.date) == currentYear
        }.reduce(0) { $0 + $1.amount }
    }

    var monthlyExpenses: Int {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        return transactions.filter {
            $0.type != .donation &&
            calendar.component(.month, from: $0.date) == currentMonth &&
            calendar.component(.year, from: $0.date) == currentYear
        }.reduce(0) { $0 + $1.amount }
    }

    var recentTransactions: [Transaction] {
        Array(transactions.sorted { $0.date > $1.date }.prefix(10))
    }

    struct DonorRow: Identifiable {
        let id: UUID
        let name: String
        let amount: Int
    }

    var topDonors: [DonorRow] {
        let donations = transactions.filter { $0.type == .donation && $0.memberId != nil }
        let donationsByMember = Dictionary(grouping: donations, by: { $0.memberId! })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }

        let rows: [DonorRow] = donationsByMember.compactMap { memberId, amount in
            guard let member = members.first(where: { $0.id == memberId }) else { return nil }
            return DonorRow(id: memberId, name: member.name, amount: amount)
        }

        return rows.sorted { $0.amount > $1.amount }
    }

    struct MonthlyStat: Identifiable {
        let id = UUID()
        let month: String
        let income: Int
        let expenses: Int
    }

    var monthlyStats: [MonthlyStat] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM"

        let last6Months = (0..<6)
            .compactMap { calendar.date(byAdding: .month, value: -$0, to: Date()) }
            .reversed()

        return last6Months.map { date in
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)

            let income = transactions.filter {
                $0.type == .donation &&
                calendar.component(.month, from: $0.date) == month &&
                calendar.component(.year, from: $0.date) == year
            }.reduce(0) { $0 + $1.amount }

            let expenses = transactions.filter {
                $0.type != .donation &&
                calendar.component(.month, from: $0.date) == month &&
                calendar.component(.year, from: $0.date) == year
            }.reduce(0) { $0 + $1.amount }

            return MonthlyStat(month: formatter.string(from: date), income: income, expenses: expenses)
        }
    }

    struct TransactionDistribution: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let colorHex: String
        let amount: Int

        var color: Color {
            switch colorHex {
            case "green": return .guildGreen
            case "gold": return .guildGold
            default: return .guildDark
            }
        }
    }

    var transactionDistribution: [TransactionDistribution] {
        let grouped = Dictionary(grouping: transactions, by: { $0.type })
        return grouped.map { type, txs in
            let colorHex: String = {
                switch type {
                case .donation: return "green"
                case .withdrawal, .reward, .repair, .purchase: return "gold"
                case .other: return "dark"
                }
            }()
            return TransactionDistribution(
                name: type.rawValue,
                icon: type.icon,
                colorHex: colorHex,
                amount: txs.reduce(0) { $0 + $1.amount }
            )
        }.sorted { $0.amount > $1.amount }
    }

    // MARK: - CRUD
    func addMember(_ member: GuildMember) {
        members.append(member)
        saveToUserDefaults()
    }

    func updateMember(_ member: GuildMember) {
        guard let index = members.firstIndex(where: { $0.id == member.id }) else { return }
        members[index] = member
        saveToUserDefaults()
    }

    func deleteMember(_ member: GuildMember) {
        members.removeAll { $0.id == member.id }
        transactions = transactions.map { tx in
            guard tx.memberId == member.id else { return tx }
            var updated = tx
            updated.memberId = nil
            updated.memberName = nil
            return updated
        }
        saveToUserDefaults()
    }

    func toggleActive(_ member: GuildMember) {
        guard let index = members.firstIndex(where: { $0.id == member.id }) else { return }
        members[index].isActive.toggle()
        saveToUserDefaults()
    }

    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        applyTransactionImpact(transaction, direction: .add)
        saveToUserDefaults()
    }

    func updateTransaction(_ transaction: Transaction) {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else { return }
        let old = transactions[index]
        applyTransactionImpact(old, direction: .remove)
        transactions[index] = transaction
        applyTransactionImpact(transaction, direction: .add)
        saveToUserDefaults()
    }

    func deleteTransaction(_ transaction: Transaction) {
        guard let existing = transactions.first(where: { $0.id == transaction.id }) else { return }
        transactions.removeAll { $0.id == transaction.id }
        applyTransactionImpact(existing, direction: .remove)
        saveToUserDefaults()
    }

    func addResource(_ resource: Resource) {
        resources.append(resource)
        saveToUserDefaults()
    }

    func updateResource(_ resource: Resource) {
        guard let index = resources.firstIndex(where: { $0.id == resource.id }) else { return }
        resources[index] = resource
        saveToUserDefaults()
    }

    func deleteResource(_ resource: Resource) {
        resources.removeAll { $0.id == resource.id }
        saveToUserDefaults()
    }

    func addResourceQuantity(_ resource: Resource, amount: Int) {
        guard let index = resources.firstIndex(where: { $0.id == resource.id }) else { return }
        resources[index].quantity += max(0, amount)
        resources[index].lastUpdated = Date()
        saveToUserDefaults()
    }

    func removeResourceQuantity(_ resource: Resource, amount: Int) {
        guard let index = resources.firstIndex(where: { $0.id == resource.id }) else { return }
        resources[index].quantity = max(0, resources[index].quantity - max(0, amount))
        resources[index].lastUpdated = Date()
        saveToUserDefaults()
    }

    func addGoal(_ goal: GuildGoal) {
        goals.append(goal)
        saveToUserDefaults()
    }

    func updateGoal(_ goal: GuildGoal) {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[index] = goal
        saveToUserDefaults()
    }

    func deleteGoal(_ goal: GuildGoal) {
        goals.removeAll { $0.id == goal.id }
        saveToUserDefaults()
    }

    func completeGoal(_ goal: GuildGoal) {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[index].isCompleted = true
        saveToUserDefaults()
    }

    // MARK: - Persistence
    private let membersKey = "guildbank_members"
    private let transactionsKey = "guildbank_transactions"
    private let resourcesKey = "guildbank_resources"
    private let goalsKey = "guildbank_goals"

    func saveToUserDefaults() {
        if let encoded = UserDefaultsStore.encode(members) {
            UserDefaults.standard.set(encoded, forKey: membersKey)
        }
        if let encoded = UserDefaultsStore.encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: transactionsKey)
        }
        if let encoded = UserDefaultsStore.encode(resources) {
            UserDefaults.standard.set(encoded, forKey: resourcesKey)
        }
        if let encoded = UserDefaultsStore.encode(goals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: membersKey),
           let decoded = UserDefaultsStore.decode([GuildMember].self, from: data) {
            members = decoded
        }

        if let data = UserDefaults.standard.data(forKey: transactionsKey),
           let decoded = UserDefaultsStore.decode([Transaction].self, from: data) {
            transactions = decoded
        }

        if let data = UserDefaults.standard.data(forKey: resourcesKey),
           let decoded = UserDefaultsStore.decode([Resource].self, from: data) {
            resources = decoded
        }

        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = UserDefaultsStore.decode([GuildGoal].self, from: data) {
            goals = decoded
        }

        if members.isEmpty && transactions.isEmpty && resources.isEmpty && goals.isEmpty {
            loadDemoData()
            saveToUserDefaults()
        }
    }

    // MARK: - Internals
    private enum ImpactDirection { case add, remove }

    private func applyTransactionImpact(_ transaction: Transaction, direction: ImpactDirection) {
        let sign: Int = (direction == .add) ? 1 : -1

        if let memberId = transaction.memberId,
           let memberIndex = members.firstIndex(where: { $0.id == memberId }) {
            if transaction.type == .donation {
                members[memberIndex].totalDonations += sign * transaction.amount
            } else {
                members[memberIndex].totalWithdrawals += sign * transaction.amount
            }
        }

        if transaction.type == .donation {
            for i in goals.indices where !goals[i].isCompleted {
                goals[i].currentAmount += sign * transaction.amount
                if goals[i].currentAmount >= goals[i].targetAmount {
                    goals[i].isCompleted = true
                }
                if goals[i].currentAmount < 0 {
                    goals[i].currentAmount = 0
                }
            }
        }
    }

    private func loadDemoData() {
        let master = GuildMember(
            id: UUID(),
            name: "Alex",
            rank: "Guild Master",
            class_: "Knight",
            level: 80,
            joinedDate: Date().addingTimeInterval(-86400 * 180),
            totalDonations: 15_000,
            totalWithdrawals: 2_000,
            notes: "Founder",
            isActive: true,
            createdAt: Date()
        )

        let officer = GuildMember(
            id: UUID(),
            name: "Elena",
            rank: "Officer",
            class_: "Mage",
            level: 78,
            joinedDate: Date().addingTimeInterval(-86400 * 150),
            totalDonations: 8_000,
            totalWithdrawals: 1_000,
            notes: nil,
            isActive: true,
            createdAt: Date()
        )

        members = [master, officer]

        let donation = Transaction(
            id: UUID(),
            date: Date().addingTimeInterval(-86400 * 2),
            type: .donation,
            currency: .gold,
            amount: 5_000,
            memberId: master.id,
            memberName: master.name,
            description: "Raid fund donation",
            relatedItem: nil,
            quantity: 1,
            approvedBy: "Alex",
            notes: nil,
            isFavorite: true,
            createdAt: Date()
        )

        let reward = Transaction(
            id: UUID(),
            date: Date().addingTimeInterval(-86400 * 5),
            type: .reward,
            currency: .gold,
            amount: 1_000,
            memberId: officer.id,
            memberName: officer.name,
            description: "Activity reward",
            relatedItem: nil,
            quantity: 1,
            approvedBy: "Alex",
            notes: nil,
            isFavorite: false,
            createdAt: Date()
        )

        transactions = [donation, reward]

        let resource = Resource(
            id: UUID(),
            name: "Adamant ore",
            type: .materials,
            quantity: 150,
            minStock: 50,
            location: "Guild vault",
            notes: "For legendary crafting",
            lastUpdated: Date()
        )

        resources = [resource]

        let goal = GuildGoal(
            id: UUID(),
            name: "Legendary weapon crafting",
            targetAmount: 50_000,
            currentAmount: 15_000,
            currency: .gold,
            deadline: Date().addingTimeInterval(86400 * 30),
            isCompleted: false,
            notes: "For raid leader",
            createdAt: Date()
        )

        goals = [goal]
    }
}

