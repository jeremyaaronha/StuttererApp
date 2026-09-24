import SwiftUI

// main screen after sign in a tab bar giving access to the app major sections
struct MainTabView: View {

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var auth: AuthManager

    // lets us save if the app is backgrounded or killed mid-session
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var audioManager = AudioManager()


    var body: some View {

        ZStack {

            TabView(selection: $appState.selectedTab) {

                PracticeView()
                    .tabItem {
                        Label("Practice", systemImage: "waveform")
                    }
                    .tag(MainTab.practice)


                ControlsView(audioManager: audioManager)
                    .tabItem {
                        Label("Controls", systemImage: "slider.horizontal.3")
                    }
                    .tag(MainTab.controls)


                TextsView()
                    .tabItem {
                        Label("Texts", systemImage: "text.book.closed")
                    }
                    .tag(MainTab.texts)


                ChallengesView()
                    .tabItem {
                        Label("Challenges", systemImage: "quote.bubble")
                    }
                    .tag(MainTab.challenges)


                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(MainTab.profile)
            }
            .tint(Theme.accent)


            // slide in side menu overlay opened by the hamburger button
            if appState.isMenuOpen {

                SideMenu()
                    .zIndex(1)
            }
        }
        .onAppear {

            // load saved audio settings for the current user
            audioManager.loadSettings(
                for: auth.userID ?? "guest"
            )
        }
        .onChange(of: scenePhase) { _, newPhase in

            // a drag that never ended, or an app about to be killed in the
            // background, would otherwise lose the last change
            if newPhase != .active {
                audioManager.saveSettings()
            }
        }
    }
}


// preview open this file to see the full tab bar
struct MainTabView_Previews: PreviewProvider {

    static var previews: some View {

        MainTabView()
            .environmentObject(AppState())
            .environmentObject(AuthManager())
            .preferredColorScheme(.dark)
    }
}
