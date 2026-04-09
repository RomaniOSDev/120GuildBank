import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Track guild treasury",
            subtitle: "Log every donation and spending action in one place.",
            systemImage: "crown.fill",
            startColor: .guildGold,
            endColor: .guildGreen
        ),
        OnboardingPage(
            title: "Manage members & rewards",
            subtitle: "Keep members active, transparent, and fairly rewarded.",
            systemImage: "person.3.fill",
            startColor: .guildGreen,
            endColor: .guildGold
        ),
        OnboardingPage(
            title: "Control goals and stock",
            subtitle: "Watch progress and react quickly to low resources.",
            systemImage: "target",
            startColor: .guildGold,
            endColor: .guildGreen
        )
    ]

    var body: some View {
        ZStack {
            Color.clear.guildScreenBackground()

            VStack(spacing: 20) {
                topBar

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                            .padding(.horizontal)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                bottomControls
                    .padding(.horizontal)
                    .padding(.bottom, 24)
            }
            .padding(.top, 12)
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button("Skip") {
                finishOnboarding()
            }
            .foregroundColor(.white.opacity(0.85))
            .font(.subheadline.bold())
        }
        .padding(.horizontal)
    }

    private var bottomControls: some View {
        HStack(spacing: 12) {
            if currentPage > 0 {
                Button("Back") {
                    withAnimation(.easeInOut) { currentPage -= 1 }
                }
                .font(.headline)
                .guildGradientButton(start: .gray.opacity(0.8), end: .black.opacity(0.7))
            }

            Button(currentPage == pages.count - 1 ? "Get started" : "Next") {
                if currentPage == pages.count - 1 {
                    finishOnboarding()
                } else {
                    withAnimation(.easeInOut) { currentPage += 1 }
                }
            }
            .font(.headline)
            .guildGradientButton(start: .guildGold, end: .guildGreen)
        }
    }

    private func finishOnboarding() {
        hasSeenOnboarding = true
    }
}

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
    let startColor: Color
    let endColor: Color
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [page.startColor.opacity(0.35), page.endColor.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 220, height: 220)
                    .shadow(color: page.startColor.opacity(0.35), radius: 24, x: 0, y: 14)

                Image(systemName: page.systemImage)
                    .font(.system(size: 78, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }

            Spacer()
        }
        .padding()
        .background(Color.guildGold.opacity(0.08))
        .guildCard(border: page.startColor)
    }
}

