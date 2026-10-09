import SwiftUI

// shows the eight ordered challenges for one target sound
struct ChallengeGridView: View {

    @EnvironmentObject private var progress: ChallengeProgressStore
    @Environment(\.dismiss) private var dismiss

    let sound: SpeechSound

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    ChallengeNavBar(
                        title: sound.name,
                        subtitle: "FLUENCY-BUILDING EXERCISES",
                        onBack: { dismiss() }
                    )

                    progressCard

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(sound.challenges) { challenge in
                            NavigationLink {
                                ChallengeDetailView(
                                    sound: sound,
                                    challenge: challenge
                                )
                                .environmentObject(progress)
                            } label: {
                                challengeCard(challenge)
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                }
                .padding(24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    // progress bar showing mastered challenges
    private var progressCard: some View {
        let completed = progress.completedCount(for: sound)
        let total = sound.challenges.count
        let fraction = total > 0 ? Double(completed) / Double(total) : 0

        return GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(sound.symbol) Sound Progress")
                            .font(.subheadline.weight(.semibold))
                        Text("\(completed) of \(total) challenges mastered")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                ProgressView(value: fraction)
                    .tint(Theme.accent)
                    .animation(.easeInOut(duration: 0.5), value: fraction)
            }
        }
    }

    // a single challenge card in the grid
    private func challengeCard(_ challenge: SpeechChallenge) -> some View {
        let done = progress.isCompleted(challenge.id)

        return GlassCard {
            VStack(alignment: .leading, spacing: 10) {

                HStack {
                    Text("#\(challenge.index)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    if done {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: done)

                Text(challenge.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                DifficultyPill(difficulty: challenge.difficulty)
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        }
    }
}

// small coloured pill showing a challenge difficulty
struct DifficultyPill: View {
    let difficulty: ChallengeDifficulty

    var body: some View {
        Text(difficulty.label)
            .font(.caption2.weight(.semibold))
            .foregroundColor(difficulty.tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(difficulty.tint.opacity(0.18))
            .clipShape(Capsule())
    }
}

// reusable top bar for pushed challenge screens with a back button
struct ChallengeNavBar: View {
    @EnvironmentObject private var appState: AppState

    let title: String
    let subtitle: String
    let onBack: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Theme.accent)
                    .frame(width: 44, height: 44)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .accessibilityLabel("Back")

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title2.weight(.bold))
                Text(subtitle)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    appState.isMenuOpen = true
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .accessibilityLabel("Open menu")
        }
    }
}
