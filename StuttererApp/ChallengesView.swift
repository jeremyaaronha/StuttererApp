import SwiftUI

// optional sprint 4 enhancement speech sound challenges
// placeholder for now just a black screen with a way to navigate back
// the real feature th sh ch practice etc will be built later if possible
struct ChallengesView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 20) {

                ScreenHeader(title: "Challenges", subtitle: "SPEECH SOUND PRACTICE")

                Spacer()

                Image(systemName: "quote.bubble")
                    .font(.system(size: 56))
                    .foregroundColor(Theme.accent)

                Text("Speech Sound Challenges")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)

                Text("Optional enhancement coming in a later sprint.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                // navigation back to the practice home
                Button {
                    appState.selectedTab = .practice
                } label: {
                    Label("Back to Practice", systemImage: "arrow.left")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Theme.accentGradient)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding(24)
        }
    }
}

// preview open this file to see the challenges placeholder screen
struct ChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengesView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}
