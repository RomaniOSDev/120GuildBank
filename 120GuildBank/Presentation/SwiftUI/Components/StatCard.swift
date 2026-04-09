import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let cardColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            Text(value)
                .foregroundColor(.white)
                .font(.title2)
                .bold()
        }
        .padding()
        .frame(width: 160, alignment: .leading)
        .background(cardColor)
        .guildCard(border: color)
    }
}

