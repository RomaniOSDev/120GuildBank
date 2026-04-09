import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GuildBankViewModel()
    @State private var selectedTab = 0
    @AppStorage("guildbank_has_seen_onboarding") private var hasSeenOnboarding = false

    var body: some View {
        mainTabs
        .onAppear { viewModel.loadFromUserDefaults() }
        .accentColor(.guildGold)
        .tint(.guildGold)
        .fullScreenCover(isPresented: onboardingBinding) {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }
    }

    private var mainTabs: some View {
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

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(5)
        }
    }

    private var onboardingBinding: Binding<Bool> {
        Binding(
            get: { !hasSeenOnboarding },
            set: { newValue in
                if !newValue { hasSeenOnboarding = true }
            }
        )
    }
}

#Preview {
    ContentView()
}

