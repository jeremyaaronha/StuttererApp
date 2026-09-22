import SwiftUI

// main screen after sign in a tab bar giving access to the app major sections
struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var audioManager = AudioManager()

    var body: some View {
        ZStack {
            TabView(selection: $appState.selectedTab) {
                PracticeView()
                    .tabItem { Label("Practice", systemImage: "waveform") }
                    .tag(MainTab.practice)

                ControlsView(audioManager: audioManager)
                    .tabItem { Label("Controls", systemImage: "slider.horizontal.3") }
                    .tag(MainTab.controls)

                TextsView()
                    .tabItem { Label("Texts", systemImage: "text.book.closed") }
                    .tag(MainTab.texts)

                ChallengesView()
                    .tabItem { Label("Challenges", systemImage: "quote.bubble") }
                    .tag(MainTab.challenges)

                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                    .tag(MainTab.profile)
            }
            .tint(Theme.accent)

            // slide in side menu overlay opened by the hamburger button
            if appState.isMenuOpen {
                SideMenu()
                    .zIndex(1)
            }
        }
    }
}

// preview open this file to see the full tab bar
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}
