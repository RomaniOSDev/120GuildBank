import SwiftUI
import StoreKit

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.guildScreenBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        header

                        actionButton(
                            title: "Rate Us",
                            icon: "star.bubble.fill",
                            start: .guildGold,
                            end: .guildGreen,
                            action: rateApp
                        )

                        actionButton(
                            title: "Privacy Policy",
                            icon: "lock.shield.fill",
                            start: .guildGreen,
                            end: .guildGold,
                            action: openPrivacyPolicy
                        )

                        actionButton(
                            title: "Terms of Use",
                            icon: "doc.text.fill",
                            start: .guildGold,
                            end: .guildGreen,
                            action: openTerms
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preferences")
                .font(.title2.bold())
                .foregroundColor(.white)

            Text("Manage app information and useful links.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.guildGold.opacity(0.08))
        .guildCard(border: .guildGold)
    }

    private func actionButton(
        title: String,
        icon: String,
        start: Color,
        end: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                Text(title)
                    .font(.headline)
                Spacer()
                Image(systemName: "arrow.up.forward")
                    .font(.subheadline.bold())
            }
            .guildGradientButton(start: start, end: end)
        }
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: ExternalLink.privacyPolicy.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func openTerms() {
        if let url = URL(string: ExternalLink.termsOfUse.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

