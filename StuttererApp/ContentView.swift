import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var auth: AuthManager

    @State private var showSplash = true

    var body: some View {

        ZStack {

            if auth.isSignedIn {
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
            .environmentObject(AuthManager())
            .preferredColorScheme(.dark)
    }
}
