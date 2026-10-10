import SwiftUI

// profile tab with a simple menu
struct ProfileView: View {

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var auth: AuthManager
    @State private var showingHelpFAQ = false
    @State private var showingAboutDAF = false
    @State private var showingEditProfile = false

    // the signed in user's name and photo
    @StateObject private var profile = ProfileStore()

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

                    profileHeader
                        .padding(.top, 12)
                        .appearCard()

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
                    .appearCard(delay: 0.08)

                    // signs out of firebase, which sends the app back to the login screen
                    Button {
                        auth.signOut()
                        profile.clear()
                        appState.signOut()
                    } label: {
                        Label("Sign Out", systemImage: "arrow.right.square")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.card)
                            .foregroundColor(.red)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PressableButtonStyle())
                    .appearCard(delay: 0.16)

                    Text("StuttererApp v1.0")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .appearCard(delay: 0.2)
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
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(store: profile, email: auth.userEmail)
        }
        // loads again whenever a different user signs in
        .task(id: auth.userID) {
            if let userID = auth.userID {
                await profile.load(userID: userID)
            }
        }
    }

    // photo, name, email, and the edit button at the top of the screen
    private var profileHeader: some View {
        VStack(spacing: 8) {
            ProfilePhoto(data: profile.photoData, size: 80)

            Text(profile.fullName ?? appState.userName)
                .font(.title3.weight(.bold))

            Text(auth.userEmail ?? "StuttererApp Account")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                showingEditProfile = true
            } label: {
                Label("Edit Profile", systemImage: "pencil")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.bordered)
            .disabled(auth.userID == nil)
            .padding(.top, 4)
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
                            answer: "Yes. Headphones are required to hear the delayed voice feedback "
                                + "correctly and avoid audio feedback from the speaker. You can use wired "
                                + "or Bluetooth headphones."
                        )

                        faqItem(
                            question: "Why does the app need microphone access?",
                            answer: "The microphone is used to hear your voice and return the delayed audio while you practice."
                        )

                        faqItem(
                            question: "What are saved practice texts?",
                            answer: "You can create and save texts in the Texts tab. Your texts are "
                                + "saved to your account so you can use them again later."
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
            .environmentObject(AuthManager())
            .preferredColorScheme(.dark)
    }
}
