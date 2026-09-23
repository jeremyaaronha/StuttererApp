import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var appState: AppState

    // controls how long the splash is visible
    @State private var showSplash = true

    var body: some View {

        ZStack {

            if appState.isSignedIn {
                MainTabView()
            } else {
                WelcomeView()
            }

            if showSplash {

                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {

            // hold the splash briefly then fade it out
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 3
            ) {

                withAnimation(
                    .easeInOut(duration: 0.5)
                ) {

                    showSplash = false
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {

    static var previews: some View {

        ContentView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}
