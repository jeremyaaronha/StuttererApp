import SwiftUI


struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    // splash screen shows up
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

// newer xcode 15 plus only uncomment this and delete the ContentView_Previews below to use the modern preview macro
// #Preview {
//     ContentView()
//         .environmentObject(AppState())
// }

// xcode 14 compatible preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
