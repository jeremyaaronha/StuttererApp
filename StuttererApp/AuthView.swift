//
//  AuthView.swift
//  StuttererApp
//

import SwiftUI

// sign in and sign up screen
struct AuthView: View {

    // shared login state from the app
    @EnvironmentObject private var auth: AuthManager

    // true shows sign up, false shows sign in
    @State private var isSignUp = false

    // text typed by the user
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {

        // creates main background layout
        ZStack {

            // same background as the main screen
            LinearGradient(
                colors: [Color.black, Color.blue.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // organizes form elements vertically
            VStack(spacing: 20) {

                // title
                Text(isSignUp ? "Create Account" : "Sign In")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                // email field
                TextField("", text: $email, prompt: placeholder("Email"))
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .modifier(AuthFieldStyle())

                // password field
                SecureField("", text: $password, prompt: placeholder("Password"))
                    .textContentType(isSignUp ? .newPassword : .password)
                    .modifier(AuthFieldStyle())

                // only needed when creating an account
                if isSignUp {
                    SecureField("", text: $confirmPassword, prompt: placeholder("Confirm Password"))
                        .textContentType(.newPassword)
                        .modifier(AuthFieldStyle())

                    Text("At least \(AuthValidator.minPasswordLength) characters, with a letter and a number.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                }

                // shows what went wrong
                if let error = auth.errorMessage {
                    Text(error)
                        .font(.callout)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                // shows when something worked, like the reset email
                if let info = auth.infoMessage {
                    Text(info)
                        .font(.callout)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                }

                // sign in or sign up button
                Button(action: submit) {
                    ZStack {
                        if auth.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .font(.system(size: 22, weight: .bold))
                        }
                    }
                    .frame(width: 200, height: 60)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .shadow(radius: 10)
                }
                .disabled(auth.isLoading)
                .padding(.top, 10)

                // google makes the account the first time, so one button
                // works for both sign in and sign up
                Button {
                    Task { await auth.signInWithGoogle() }
                } label: {
                    Text("Continue with Google")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 240, height: 50)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(25)
                        .shadow(radius: 10)
                }
                .disabled(auth.isLoading)

                // sends a reset link, only useful when signing in
                if !isSignUp {
                    Button("Forgot password?") {
                        Task { await auth.resetPassword(email: email) }
                    }
                    .font(.footnote)
                    .foregroundColor(.cyan)
                    .disabled(auth.isLoading)
                }

                // switches between sign in and sign up
                Button(isSignUp ? "Already have an account? Sign in"
                                : "Don't have an account? Sign up") {
                    isSignUp.toggle()
                    confirmPassword = ""
                    auth.errorMessage = nil
                    auth.infoMessage = nil
                }
                .foregroundColor(.cyan)

                // warns right away instead of waiting for a button tap
                if !auth.isConfigured {
                    Text("Firebase isn't set up yet. Add GoogleService-Info.plist to the project.")
                        .font(.footnote)
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                }
            }
            .padding(.horizontal, 30)
        }
    }

    // light gray hint text that shows on the dark background
    private func placeholder(_ text: String) -> Text {
        Text(text).foregroundColor(.white.opacity(0.6))
    }

    // sends the form to the auth manager
    private func submit() {
        Task {
            if isSignUp {
                await auth.signUp(email: email,
                                  password: password,
                                  confirmPassword: confirmPassword)
            } else {
                await auth.signIn(email: email, password: password)
            }
        }
    }
}

// look shared by the text fields
private struct AuthFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white.opacity(0.15))
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}
