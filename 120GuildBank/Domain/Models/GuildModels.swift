import Foundation
import SwiftUI

enum TransactionType: String, CaseIterable, Codable, Identifiable {
    case donation = "Donation"
    case withdrawal = "Withdrawal"
    case reward = "Reward"
    case repair = "Repair"
    case purchase = "Purchase"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .donation: return "arrow.up.circle.fill"
        case .withdrawal: return "arrow.down.circle.fill"
        case .reward: return "star.fill"
        case .repair: return "wrench.fill"
        case .purchase: return "cart.fill"
        case .other: return "folder.fill"
        }
    }

    var color: Color {
        switch self {
        case .donation: return .guildGreen
        case .withdrawal, .reward, .repair, .purchase: return .guildGold
        case .other: return .guildDark
        }
    }

    var signedPrefix: String {
        self == .donation ? "+" : "-"
    }
}

enum CurrencyType: String, CaseIterable, Codable, Identifiable {
    case gold = "Gold"
    case silver = "Silver"
    case copper = "Copper"
    case tokens = "Tokens"
    case gems = "Gems"
    case points = "Guild Points"
    case custom = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .gold: return "crown.fill"
        case .silver: return "circle.fill"
        case .copper: return "circle"
        case .tokens: return "ticket.fill"
        case .gems: return "diamond.fill"
        case .points: return "star.fill"
        case .custom: return "folder.fill"
        }
    }
}

enum ResourceType: String, CaseIterable, Codable, Identifiable {
    case materials = "Materials"
    case potions = "Potions"
    case equipment = "Equipment"
    case recipes = "Recipes"
    case mounts = "Mounts"
    case pets = "Pets"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .materials: return "cube.fill"
        case .potions: return "flask.fill"
        case .equipment: return "shield.fill"
        case .recipes: return "book.fill"
        case .mounts: return "hare.fill"
        case .pets: return "pawprint.fill"
        case .other: return "folder.fill"
        }
    }
}

struct GuildMember: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var rank: String
    var class_: String?
    var level: Int?
    var joinedDate: Date
    var totalDonations: Int
    var totalWithdrawals: Int
    var notes: String?
    var isActive: Bool
    let createdAt: Date
}

struct Transaction: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var type: TransactionType
    var currency: CurrencyType
    var amount: Int
    var memberId: UUID?
    var memberName: String?
    var description: String
    var relatedItem: String?
    var quantity: Int
    var approvedBy: String?
    var notes: String?
    var isFavorite: Bool
    let createdAt: Date
}

struct Resource: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var type: ResourceType
    var quantity: Int
    var minStock: Int
    var location: String?
    var notes: String?
    var lastUpdated: Date
}

struct GuildGoal: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var targetAmount: Int
    var currentAmount: Int
    var currency: CurrencyType
    var deadline: Date?
    var isCompleted: Bool
    var notes: String?
    let createdAt: Date

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(Double(currentAmount) / Double(targetAmount), 1.0)
    }
}

struct GuildStat {
    var totalGold: Int
    var totalDonations: Int
    var totalWithdrawals: Int
    var topDonors: [(GuildMember, Int)]
    var monthlyIncome: Int
    var monthlyExpenses: Int
}

