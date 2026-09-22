import SwiftUI

// texts library tab
// sprint 1 navigation placeholder shows the reader input area and a list of saved practice texts
// saving and reading behavior is a later sprint
struct TextsView: View {

    // sample rows so the list looks real for navigation
    private let sampleTexts: [(title: String, subtitle: String)] = [
        ("Standard Phonetic Passages", "340 words • Recommended"),
        ("Self-Introduction Practice", "120 words • Edited yesterday"),
        ("The Rainbow Passage", "160 words • Speech Therapy Classic")
    ]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    ScreenHeader(title: "Texts", subtitle: "TEXTS LIBRARY")

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Speech Reader Input")
                                .font(.headline)
                            Text("Type or paste text here to read with real-time choral voice companion…")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("My Saved Practice Texts")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(sampleTexts, id: \.title) { item in
                            GlassCard {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title)
                                            .font(.subheadline.weight(.semibold))
                                        Text(item.subtitle)
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
                }
                .padding(24)
            }
        }
    }
}

// preview open this file to see the texts library screen
struct TextsView_Previews: PreviewProvider {
    static var previews: some View {
        TextsView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}
