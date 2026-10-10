import SwiftUI

// speech sound challenges tab
// shows challenges based on the selected language
struct ChallengesView: View {

    @EnvironmentObject private var auth: AuthManager
    @AppStorage("appLanguage") private var appLanguage = "en"
    @StateObject private var progress = ChallengeProgressStore()

    // sounds available for the selected language
    private var availableSounds: [SpeechSound] {
        if appLanguage == "es" {
            return SpeechCatalog.spanishSounds
        }

        return SpeechCatalog.sounds
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        ScreenHeader(
                            title: "StuttererApp",
                            subtitle: "CHALLENGE SOUNDS"
                        )

                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {

                                Text("Choose a Sound")
                                    .font(.headline)

                                Text("Select a target sound below to start specialised fluency-building speech loops.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .appearCard()

                        ForEach(availableSounds) { sound in
                            NavigationLink {
                                ChallengeGridView(sound: sound)
                                    .environmentObject(progress)
                            } label: {
                                soundRow(sound)
                            }
                            .buttonStyle(PressableButtonStyle())
                            .appearCard(delay: 0.05)
                        }
                    }
                    .padding(24)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            progress.load(for: auth.userID ?? "guest")
        }
    }

    // a single sound row with its badge, name, and completion count
    private func soundRow(_ sound: SpeechSound) -> some View {
        let completed = progress.completedCount(for: sound)
        let total = sound.challenges.count

        return GlassCard {
            HStack(spacing: 16) {

                Text(sound.symbol)
                    .font(.headline.weight(.bold))
                    .foregroundColor(Theme.accent)
                    .frame(width: 48, height: 48)
                    .background(Theme.accent.opacity(0.15))
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                    )

                VStack(alignment: .leading, spacing: 4) {

                    Text(LocalizedStringKey(sound.name))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)

                    Text("\(completed) of \(total) completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// preview open this file to see the challenge sounds list
struct ChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengesView()
            .environmentObject(AppState())
            .environmentObject(AuthManager())
            .preferredColorScheme(.dark)
    }
}
