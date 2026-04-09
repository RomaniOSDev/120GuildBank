//
//  ContentView.swift
//  120GuildBank
//
//  Created by Роман Главацкий on 08.04.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GuildBankViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(viewModel: viewModel)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            MembersView(viewModel: viewModel)
                .tabItem { Label("Members", systemImage: "person.3.fill") }
                .tag(1)

            ResourcesView(viewModel: viewModel)
                .tabItem { Label("Resources", systemImage: "cube.fill") }
                .tag(2)

            GoalsView(viewModel: viewModel)
                .tabItem { Label("Goals", systemImage: "target") }
                .tag(3)

            StatsView(viewModel: viewModel)
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
                .tag(4)
        }
        .onAppear { viewModel.loadFromUserDefaults() }
        .accentColor(.guildGold)
        .tint(.guildGold)
    }
}

#Preview {
    ContentView()
}
