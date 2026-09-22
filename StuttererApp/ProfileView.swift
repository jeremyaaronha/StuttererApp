import SwiftUI

// profile tab with a simple menu
// sign out returns to the welcome screen menu items are navigation targets for later sprints
struct ProfileView: View {
    @EnvironmentObject private var appState: AppState

    // placeholder menu rows
    private let menuItems: [(title: String, systemImage: String)] = [
        ("Practice Board", "waveform"),
        ("Delay Tuning Engine", "slider.horizontal.3"),
        ("My Reading Library", "text.book.closed"),
        ("Help & FAQ", "questionmark.circle"),
        ("About DAF Technique", "book")
    ]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(Theme.accent)
                        Text(appState.userName)
                            .font(.title3.weight(.bold))
                        Text("StuttererApp Account")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 12)

                    GlassCard {
                        VStack(spacing: 0) {
                            ForEach(Array(menuItems.enumerated()), id: \.element.title) { index, item in
                                HStack(spacing: 14) {
                                    Image(systemName: item.systemImage)
                                        .foregroundColor(Theme.accent)
                                        .frame(width: 24)
                                    Text(item.title)
                                        .font(.subheadline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 12)

                                if index < menuItems.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }

                    // sign out returns to the welcome screen
                    Button(action: appState.signOut) {
                        Label("Sign Out", systemImage: "arrow.right.square")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.card)
                            .foregroundColor(.red)
                            .clipShape(Capsule())
                    }

                    Text("StuttererApp v1.0")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(24)
            }
        }
    }
}

// preview open this file to see the profile screen
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}
