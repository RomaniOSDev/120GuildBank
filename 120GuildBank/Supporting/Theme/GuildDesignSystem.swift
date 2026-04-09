import SwiftUI

struct GuildScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [Color.guildDark, Color.guildDark.opacity(0.92), Color.black.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
    }
}

struct GuildGlassCard: ViewModifier {
    let borderColor: Color

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor.opacity(0.45), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: borderColor.opacity(0.2), radius: 10, x: 0, y: 6)
            .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 10)
    }
}

struct GuildGradientButton: ViewModifier {
    let start: Color
    let end: Color

    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .cornerRadius(12)
            .shadow(color: end.opacity(0.35), radius: 10, x: 0, y: 6)
    }
}

extension View {
    func guildScreenBackground() -> some View {
        modifier(GuildScreenBackground())
    }

    func guildCard(border: Color = .guildGold) -> some View {
        modifier(GuildGlassCard(borderColor: border))
    }

    func guildGradientButton(start: Color = .guildGold, end: Color = .guildGreen) -> some View {
        modifier(GuildGradientButton(start: start, end: end))
    }
}

