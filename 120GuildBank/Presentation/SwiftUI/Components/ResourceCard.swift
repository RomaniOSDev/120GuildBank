import SwiftUI

struct ResourceCard: View {
    let resource: Resource

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: resource.type.icon)
                    .foregroundColor(.guildGold)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.name)
                        .foregroundColor(.white)
                        .font(.headline)

                    Text(resource.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Text("x\(resource.quantity)")
                    .foregroundColor(resource.quantity <= resource.minStock ? .guildGold : .guildGreen)
                    .font(.title2)
                    .bold()
            }

            if let location = resource.location, !location.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            if resource.quantity <= resource.minStock {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.guildGold)
                    Text("Low stock! Minimum: \(resource.minStock)")
                        .font(.caption)
                        .foregroundColor(.guildGold)
                }
            }
        }
        .padding()
        .background(Color.guildGold.opacity(0.06))
        .guildCard(border: .guildGold)
    }
}

