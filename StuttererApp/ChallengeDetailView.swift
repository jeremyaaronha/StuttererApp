import SwiftUI

// detail screen for a single challenge
// shows the practice prompt, technique guidance, and a live recording check
struct ChallengeDetailView: View {

    @EnvironmentObject private var progress: ChallengeProgressStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var recognizer = SpeechChallengeRecognizer()

    let sound: SpeechSound
    let challenge: SpeechChallenge

    @State private var didComplete = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    ChallengeNavBar(
                        title: "\(challenge.title) Challenge",
                        subtitle: "FLUENCY-BUILDING EXERCISE",
                        onBack: { dismiss() }
                    )

                    Text("\(challenge.difficulty.label.uppercased()) FLUENCY CHALLENGE")
                        .font(.caption.weight(.bold))
                        .foregroundColor(challenge.difficulty.tint)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(challenge.difficulty.tint.opacity(0.18))
                        .clipShape(Capsule())

                    promptCard

                    tipsCard

                    if recognizer.authorizationDenied {
                        Text("Enable microphone and speech recognition in Settings to use recording.")
                            .font(.footnote)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                    }

                    if let result = recognizer.lastResult, !recognizer.isRecording {
                        resultCard(result)
                    }

                    Text("Speak the sentence aloud using gentle \(sound.symbol) placement.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    recordButton
                }
                .padding(24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            didComplete = progress.isCompleted(challenge.id)
            recognizer.requestAuthorization()
        }
        .onDisappear {
            if recognizer.isRecording {
                recognizer.stop()
            }
        }
    }

    // the fluency sentence with the target sound words highlighted
    private var promptCard: some View {
        GlassCard {
            VStack(spacing: 12) {
                Text("FLUENCY SENTENCE")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.secondary)

                HighlightedPromptText(
                    prompt: challenge.prompt,
                    patterns: challenge.patterns
                )
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

                HStack(spacing: 6) {
                    Image(systemName: "waveform.circle")
                        .foregroundColor(Theme.accent)
                    Text(challenge.hint)
                        .font(.caption)
                        .foregroundColor(Theme.accent)
                }
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // fluency tips built from the sound placement tip and the technique tip
    private var tipsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("FLUENCY TIPS")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)

                tipRow(sound.placementTip)
                tipRow(challenge.techniqueTip)
            }
        }
    }

    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(Theme.accent)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // feedback shown after a recording attempt
    private func resultCard(_ result: ChallengeResult) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {

                HStack(spacing: 8) {
                    Image(systemName: result.passed ? "checkmark.seal.fill" : "arrow.clockwise.circle.fill")
                        .foregroundColor(result.passed ? .green : .orange)
                    Text(result.passed ? "Great work!" : "Keep practicing")
                        .font(.headline)
                }

                Text("You hit \(result.matchedTargets.count) of \(result.totalTargets) target \(sound.symbol) words.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if result.repetitions > 0 {
                    Text("Noticed \(result.repetitions) repeated word\(result.repetitions == 1 ? "" : "s") — try an easy, smooth restart next time.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !recognizer.transcript.isEmpty {
                    Text("Heard: \"\(recognizer.transcript)\"")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }

                if didComplete {
                    Label("Challenge mastered", systemImage: "trophy.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.accent)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // start or stop the live recording check
    private var recordButton: some View {
        Button {
            toggleRecording()
        } label: {
            Label(
                recognizer.isRecording ? "Stop Recording" : "Start Recording",
                systemImage: recognizer.isRecording ? "stop.fill" : "mic.fill"
            )
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(recognizer.isRecording ? AnyShapeStyle(Color.red) : AnyShapeStyle(Theme.accentGradient))
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .disabled(recognizer.authorizationDenied)
    }

    private func toggleRecording() {
        if recognizer.isRecording {
            let result = recognizer.stop()
            if result.passed {
                progress.markCompleted(challenge.id)
                didComplete = true
            }
        } else {
            recognizer.start(
                prompt: challenge.prompt,
                patterns: challenge.patterns
            )
        }
    }
}

// renders a prompt with the target sound words bolded and tinted
struct HighlightedPromptText: View {
    let prompt: String
    let patterns: [String]

    var body: some View {
        let words = prompt
            .split(separator: " ", omittingEmptySubsequences: false)
            .map(String.init)

        return words.enumerated().reduce(Text("")) { partial, item in
            let (index, word) = item
            let isTarget = patterns.contains {
                word.lowercased().contains($0.lowercased())
            }

            let piece = Text(word)
                .foregroundColor(isTarget ? Theme.accent : .white)
                .fontWeight(isTarget ? .bold : .regular)

            let separator = index == words.count - 1 ? Text("") : Text(" ")
            return partial + piece + separator
        }
    }
}
