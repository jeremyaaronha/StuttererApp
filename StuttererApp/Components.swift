import SwiftUI

enum Theme {

    // primary accent used for interactive elements and highlights
    static let accent = Color.cyan

    // green used for the start action like the original
    static let start = Color.green

    // soft dark background gradient used behind every screen
    static let background = LinearGradient(
        colors: [Color.black, Color.blue.opacity(0.6)],
        startPoint: .top,
        endPoint: .bottom
    )

    // subtle translucent dark gradient used to fill cards
    static let card = LinearGradient(
        colors: [
            Color.white.opacity(0.10),
            Color.white.opacity(0.04)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // gradient used for primary buttons and highlights
    static let accentGradient = LinearGradient(
        colors: [Color.cyan, Color.blue],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// a rounded soft card used to group content on a screen
struct GlassCard<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
    }
}

// a reusable top bar with a title subtitle and a hamburger button
// the hamburger opens the slide in side menu
struct ScreenHeader: View {
    @EnvironmentObject private var appState: AppState

    var title: String
    var subtitle: String

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title2.weight(.bold))
                Text(subtitle)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    appState.isMenuOpen = true
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .accessibilityLabel("Open menu")
        }
    }
}

// a single status pill for example mic connected
struct StatusPill: View {
    var systemImage: String
    var title: String
    var isActive: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(title)
                .font(.subheadline.weight(.medium))
        }
        .foregroundColor(isActive ? Theme.accent : .secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.card)
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

// shows the current device status clearly mic plus headphones
struct StatusIndicator: View {
    var isMicConnected: Bool
    var areHeadphonesConnected: Bool

    var body: some View {
        HStack {
            StatusPill(
                systemImage: isMicConnected ? "mic.fill" : "mic.slash.fill",
                title: isMicConnected ? "Mic Connected" : "Mic Off",
                isActive: isMicConnected
            )
            Spacer()
            StatusPill(
                systemImage: areHeadphonesConnected ? "headphones" : "headphones.circle",
                title: areHeadphonesConnected ? "Headphones On" : "No Headphones",
                isActive: areHeadphonesConnected
            )
        }
    }
}

// banner telling the user that headphones are required to hear audio feedback
struct HeadphoneRequirementBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "headphones")
                .font(.title3)
                .foregroundColor(Theme.accent)
            Text("Headphones are required to hear the delayed audio feedback.")
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    Theme.accent.opacity(0.12),
                    Theme.accent.opacity(0.04)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
