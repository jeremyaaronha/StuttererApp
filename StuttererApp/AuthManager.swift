//
//  AuthManager.swift
//  StuttererApp
//

import Foundation
import Combine
import FirebaseCore
import FirebaseAuth

// handles sign up, sign in, sign out, and keeping the user logged in
@MainActor
final class AuthManager: ObservableObject {

    // true when a user is logged in
    @Published private(set) var isSignedIn = false

    // email of the logged in user
    @Published private(set) var userEmail: String?

    // message shown to the user when something goes wrong
    @Published var errorMessage: String?

    // true while waiting for firebase
    @Published private(set) var isLoading = false

    // false until GoogleService-Info.plist is added to the project
    let isConfigured: Bool

    // keeps the firebase login listener alive
    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        isConfigured = FirebaseApp.app() != nil
        guard isConfigured else { return }

        // firebase saves the session on the phone, so this fires on launch
        // with the saved user and again whenever they sign in or out
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            let email = user?.email
            let signedIn = user != nil
            Task { @MainActor in
                self?.isSignedIn = signedIn
                self?.userEmail = email
            }
        }
    }

    // creates a new account
    func signUp(email: String, password: String, confirmPassword: String) async {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        // checks input before calling firebase
        if let error = AuthValidator.emailError(email)
            ?? AuthValidator.passwordError(password)
            ?? AuthValidator.confirmError(password, confirmPassword) {
            errorMessage = error
            return
        }

        await run {
            try await Auth.auth().createUser(withEmail: email, password: password)
        }
    }

    // logs in to an existing account
    func signIn(email: String, password: String) async {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        // only checks the basics here, firebase decides if the login is right
        if let error = AuthValidator.emailError(email) {
            errorMessage = error
            return
        }
        if password.isEmpty {
            errorMessage = "Please enter your password."
            return
        }

        await run {
            try await Auth.auth().signIn(withEmail: email, password: password)
        }
    }

    // logs the user out
    func signOut() {
        guard isConfigured else { return }
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = message(for: error)
        }
    }

    // runs a firebase call with a loading state and friendly errors
    private func run(_ action: () async throws -> Void) async {
        guard isConfigured else {
            errorMessage = "Firebase isn't set up yet. Add GoogleService-Info.plist to the project."
            return
        }

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await action()
        } catch {
            errorMessage = message(for: error)
        }
    }

    // turns firebase errors into messages a user understands
    private func message(for error: Error) -> String {
        switch AuthErrorCode(rawValue: (error as NSError).code) {
        case .wrongPassword, .userNotFound, .invalidCredential:
            return "Incorrect email or password."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .weakPassword:
            return "That password is too weak. Try a longer one."
        case .userDisabled:
            return "This account has been disabled."
        case .tooManyRequests:
            return "Too many attempts. Please wait a moment and try again."
        case .networkError:
            return "No internet connection. Please try again."
        default:
            return error.localizedDescription
        }
    }
}
