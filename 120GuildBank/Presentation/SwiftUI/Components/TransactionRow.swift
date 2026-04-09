import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.type.icon)
                .foregroundColor(transaction.type.color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.description.isEmpty ? "Untitled" : transaction.description)
                    .foregroundColor(.white)
                    .font(.headline)
                    .lineLimit(1)

                if let memberName = transaction.memberName, !memberName.isEmpty {
                    Text(memberName)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(transaction.type.signedPrefix)\(transaction.amount) 🪙")
                    .foregroundColor(transaction.type == .donation ? .guildGreen : .guildGold)
                    .bold()

                Text(formattedShortDate(transaction.date))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.guildGold.opacity(0.06))
        .guildCard(border: transaction.type.color)
    }
}

