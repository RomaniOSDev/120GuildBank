import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: GuildBankViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.guildScreenBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        statGrid
                            .padding(.horizontal)

                        monthlyChart

                        distributionSection
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var statGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Total gold",
                value: "\(viewModel.totalGold) 🪙",
                icon: "crown.fill",
                color: .guildGold,
                cardColor: .guildGold.opacity(0.1)
            )

            StatCard(
                title: "Monthly income",
                value: "\(viewModel.monthlyIncome) 🪙",
                icon: "arrow.up.circle.fill",
                color: .guildGreen,
                cardColor: .guildGold.opacity(0.1)
            )

            StatCard(
                title: "Monthly expenses",
                value: "\(viewModel.monthlyExpenses) 🪙",
                icon: "arrow.down.circle.fill",
                color: .guildGold,
                cardColor: .guildGold.opacity(0.1)
            )

            StatCard(
                title: "Balance",
                value: "\(viewModel.totalGold) 🪙",
                icon: "scale.fill",
                color: .guildGreen,
                cardColor: .guildGold.opacity(0.1)
            )
        }
    }

    private var monthlyChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Income vs expenses (last 6 months)")
                .font(.headline)
                .foregroundColor(.guildGold)
                .padding(.horizontal)

            Chart {
                ForEach(viewModel.monthlyStats) { data in
                    BarMark(
                        x: .value("Month", data.month),
                        y: .value("Income", data.income)
                    )
                    .foregroundStyle(Color.guildGreen)

                    BarMark(
                        x: .value("Month", data.month),
                        y: .value("Expenses", data.expenses)
                    )
                    .foregroundStyle(Color.guildGold)
                }
            }
            .chartLegend(.hidden)
            .frame(height: 220)
            .padding()
            .background(Color.guildGold.opacity(0.06))
            .guildCard(border: .guildGold)
            .padding(.horizontal)
        }
    }

    private var distributionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Transaction types")
                .font(.headline)
                .foregroundColor(.guildGold)
                .padding(.horizontal)

            VStack(spacing: 8) {
                if viewModel.transactionDistribution.isEmpty {
                    Text("No data yet.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                } else {
                    ForEach(viewModel.transactionDistribution) { item in
                        HStack(spacing: 10) {
                            Image(systemName: item.icon)
                                .foregroundColor(item.color)
                                .frame(width: 30)

                            Text(item.name)
                                .foregroundColor(.white)

                            Spacer()

                            Text("\(item.amount) 🪙")
                                .foregroundColor(item.color)
                                .bold()
                        }
                        .padding(.vertical, 4)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 10)
            .background(Color.guildGold.opacity(0.06))
            .guildCard(border: .guildGold)
            .padding(.horizontal)
        }
    }
}

