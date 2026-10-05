import SwiftUI

// profile tab with a simple menu
struct ProfileView: View {

    @EnvironmentObject private var appState: AppState
    @State private var showingHelpFAQ = false
    @State private var showingAboutDAF = false

    // profile menu options
    private let menuItems: [(title: String, systemImage: String)] = [
        ("Practice Board", "waveform"),
        ("Delay Tuning Engine", "slider.horizontal.3"),
        ("My Reading Library", "text.book.closed"),
        ("Help & FAQ", "questionmark.circle"),
        ("About DAF Technique", "book")
    ]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(Theme.accent)

                        Text(appState.userName)
                            .font(.title3.weight(.bold))

                        Text("StuttererApp Account")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 12)

                    GlassCard {
                        VStack(spacing: 0) {

                            ForEach(
                                Array(menuItems.enumerated()),
                                id: \.element.title
                            ) { index, item in

                                Button {
                                    switch item.title {
                                    case "Practice Board":
                                        appState.selectedTab = .practice
                                    case "Delay Tuning Engine":
                                        appState.selectedTab = .controls
                                    case "My Reading Library":
                                        appState.selectedTab = .texts
                                    case "Help & FAQ":
                                        showingHelpFAQ = true
                                    case "About DAF Technique":
                                        showingAboutDAF = true
                                    default:
                                        break
                                    }
                                } label: {
                                    HStack(spacing: 14) {

                                        Image(systemName: item.systemImage)
                                            .foregroundColor(Theme.accent)
                                            .frame(width: 24)

                                        Text(item.title)
                                            .font(.subheadline)

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(.plain)

                                if index < menuItems.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }

                    // sign out returns to the welcome screen
                    Button(action: appState.signOut) {
                        Label(
                            "Sign Out",
                            systemImage: "arrow.right.square"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.card)
                        .foregroundColor(.red)
                        .clipShape(Capsule())
                    }

                    Text("StuttererApp v1.0")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(24)
            }
        }
        .sheet(isPresented: $showingHelpFAQ) {
            HelpFAQView()
        }
        .sheet(isPresented: $showingAboutDAF) {
            AboutDAFView()
        }
    }
}


// help and faq screen
struct HelpFAQView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        faqItem(
                            question: "How do I start a practice session?",
                            answer: "Open the Practice tab and click 'Start session'. You can adjust your voice settings from the Controls tab."
                        )

                        faqItem(
                            question: "What are the Controls?",
                            answer: "The Controls tab lets you adjust the delay of both voices, the voice effect, and the volume of the second voice."
                        )

                        faqItem(
                            question: "Do I need headphones?",
                            answer: "Yes. Headphones are required to hear the delayed voice feedback correctly and avoid audio feedback from the speaker.You can use wired or Bluetooth headphones."
                        )

                        faqItem(
                            question: "Why does the app need microphone access?",
                            answer: "The microphone is used to hear your voice and return the delayed audio while you practice."
                        )

                        faqItem(
                            question: "What are saved practice texts?",
                            answer: "You can create and save texts in the Texts tab. Your texts are saved to your account so you can use them again later."
                        )

                        faqItem(
                            question: "What is my account used for?",
                            answer: "Your account keeps your personal information, saved practice texts, and preferences connected to your user."
                        )
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Help & FAQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // shows one question and answer
    private func faqItem(
        question: String,
        answer: String
    ) -> some View {

        GlassCard {
            VStack(alignment: .leading, spacing: 8) {

                Text(question)
                    .font(.headline)

                Text(answer)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }
        }
    }
}


// preview for the profile screen
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}
