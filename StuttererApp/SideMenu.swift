import SwiftUI

// slide in side menu opened by the hamburger button
// each item just closes the menu except sign out which returns to the welcome screen
struct SideMenu: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var auth: AuthManager

    // navigation items shown in the drawer
    // items with a tab actually navigate the rest are placeholders for now
    private let items: [(title: String, systemImage: String, tab: MainTab?)] = [
        ("Practice Board", "waveform", .practice),
        ("Delay Tuning Engine", "slider.horizontal.3", .controls),
        ("My Reading Library", "text.book.closed", .texts),
        ("Speech Sound Challenges", "quote.bubble", .challenges),
        ("Therapist Reports", "chart.line.uptrend.xyaxis", nil),
        ("Settings", "gearshape", nil),
        ("Help & FAQ", "questionmark.circle", nil),
        ("About DAF Technique", "book", nil)
    ]

    var body: some View {
        ZStack(alignment: .leading) {

            // dimmed backdrop tap anywhere to close
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { close() }

            // the drawer panel
            VStack(alignment: .leading, spacing: 0) {

                // header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("StuttererApp")
                            .font(.title3.weight(.bold))
                            .foregroundColor(.white)
                        Text("MENU")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Button(action: close) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Close menu")
                }
                .padding(.top, 60)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                Divider().background(Color.white.opacity(0.15))

                // placeholder items
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(items, id: \.title) { item in
                            Button {
                                // navigate if the item has a tab otherwise just close
                                if let tab = item.tab {
                                    appState.selectedTab = tab
                                }
                                close()
                            } label: {
                                menuRow(title: item.title, systemImage: item.systemImage)
                            }
                        }
                    }
                    .padding(.top, 12)
                }

                Spacer()

                Divider().background(Color.white.opacity(0.15))

                // signs out of firebase, which sends the app back to the login screen
                Button {
                    close()
                    auth.signOut()
                    appState.signOut()
                } label: {
                    menuRow(title: "Sign Out", systemImage: "arrow.right.square", tint: .red)
                }
                .padding(.bottom, 32)
            }
            .frame(width: 280)
            .frame(maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.07, blue: 0.15), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
            .transition(.move(edge: .leading))
        }
    }

    // one row in the menu
    private func menuRow(title: String, systemImage: String, tint: Color = .white) -> some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.body)
                .foregroundColor(tint == .white ? Theme.accent : tint)
                .frame(width: 24)
            Text(title)
                .font(.body)
                .foregroundColor(tint)
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 24)
        .contentShape(Rectangle())
    }

    private func close() {
        withAnimation(.easeInOut(duration: 0.25)) {
            appState.isMenuOpen = false
        }
    }
}

// preview open this file to see the side menu
struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu()
            .environmentObject(AppState())
            .environmentObject(AuthManager())
            .preferredColorScheme(.dark)
    }
}
