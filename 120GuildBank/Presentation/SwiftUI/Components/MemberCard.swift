import SwiftUI

struct MemberCard: View {
    let member: GuildMember

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(member.name)
                        .foregroundColor(.white)
                        .font(.headline)

                    if !member.isActive {
                        Text("(inactive)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Text(member.rank)
                    .font(.caption)
                    .foregroundColor(.guildGold)

                if let class_ = member.class_, !class_.isEmpty {
                    Text(class_)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("+\(member.totalDonations) 🪙")
                    .foregroundColor(.guildGreen)
                    .bold()

                Text("-\(member.totalWithdrawals) 🪙")
                    .foregroundColor(.guildGold)

                Text("Balance: \(member.totalDonations - member.totalWithdrawals) 🪙")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.guildGold.opacity(0.06))
        .guildCard(border: .guildGold)
    }
}

