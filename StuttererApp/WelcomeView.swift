import SwiftUI

// welcome sign in entry screen
// real authentication is owned by another team member and will replace appState signIn later
struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState

    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {

                    // app identity
                    VStack(spacing: 6) {
                        Text("StuttererApp")
                            .font(.title2.weight(.bold))
                        Text("SPEECH ASSIST")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // hero
                    VStack(spacing: 12) {
                        Image(systemName: "") // get logo in here
                            .font(.system(size: 56))
                            .foregroundColor(Theme.accent)
                        Text("Choral Speech")
                            .font(.largeTitle.weight(.bold))
                        Text("Leverage two delayed feedback voices in real-time to ease speech blocks and build vocal confidence.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 12)

                    // sign in form
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Sign In to Your Account")
                                .font(.headline)

                            fieldLabel("EMAIL ADDRESS")
                            TextField("you@email.com", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .textFieldStyle(.roundedBorder)

                            fieldLabel("PASSWORD")
                            SecureField("Password", text: $password)
                                .textFieldStyle(.roundedBorder)

                            // navigation only moves into the app
                            // the auth team will add real login here later
                            Button(action: appState.signIn) {
                                Label("Sign In", systemImage: "arrow.right")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Theme.accentGradient)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            .padding(.top, 4)

                            HStack {
                                Button("Forgot Password?") {}
                                    .font(.footnote)
                                Spacer()
                                Button("Create Account", action: appState.signIn)
                                    .font(.footnote.weight(.semibold))
                            }
                            .tint(Theme.accent)
                        }
                    }

                    Text("This app generates supportive acoustic environments based on delayed auditory feedback (DAF). It is not a diagnostic medical treatment.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
            }
        }
    }

    // small field label helper
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(.secondary)
    }
}

// preview open this file to see the welcome screen on its own
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}
