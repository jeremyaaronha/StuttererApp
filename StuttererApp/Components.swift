import SwiftUI
import UIKit

// resolves to a different colour in light and dark appearance
extension Color {
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

enum Theme {

    // primary accent used for interactive elements and highlights
    static let accent = Color.adaptive(
        light: Color(red: 0.0, green: 0.52, blue: 0.70),
        dark: .cyan
    )

    // green used for the start action like the original
    static let start = Color.green

    // main text colour that stays readable in both appearances
    static let textPrimary = Color.adaptive(
        light: Color(red: 0.08, green: 0.10, blue: 0.14),
        dark: .white
    )

    // soft background gradient used behind every screen
    static let background = LinearGradient(
        colors: [
            Color.adaptive(light: Color(red: 0.96, green: 0.98, blue: 1.0), dark: .black),
            Color.adaptive(light: Color(red: 0.80, green: 0.89, blue: 0.98), dark: Color.blue.opacity(0.6))
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // translucent gradient used to fill cards
    static let card = LinearGradient(
        colors: [
            Color.adaptive(light: .white, dark: Color.white.opacity(0.10)),
            Color.adaptive(light: Color.white.opacity(0.85), dark: Color.white.opacity(0.04))
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // subtle border drawn around cards and pills
    static let cardBorder = Color.adaptive(
        light: Color.black.opacity(0.08),
        dark: Color.white.opacity(0.12)
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
                    .strokeBorder(Theme.cardBorder, lineWidth: 1)
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
            ThemePill()
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    appState.isMenuOpen = true
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(Theme.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .accessibilityLabel("Open menu")
        }
    }
}

// a pill button that switches the app between light and dark appearance
struct ThemePill: View {
    @AppStorage("isDarkMode") private var isDarkMode = true

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                isDarkMode.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                Text(isDarkMode ? "Dark" : "Light")
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(Theme.accent)
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Theme.card)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(Theme.cardBorder, lineWidth: 1)
            )
        }
        .accessibilityLabel(isDarkMode ? "Switch to light mode" : "Switch to dark mode")
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
            Capsule().strokeBorder(Theme.cardBorder, lineWidth: 1)
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

// scales a tappable view down slightly while pressed for tactile feedback
struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// fades and slides a card up as it first appears, with an optional stagger delay
struct AppearCard: ViewModifier {
    var delay: Double = 0
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 16)
            .onAppear {
                withAnimation(.easeOut(duration: 0.35).delay(delay)) {
                    shown = true
                }
            }
    }
}

extension View {
    func appearCard(delay: Double = 0) -> some View {
        modifier(AppearCard(delay: delay))
    }
}
