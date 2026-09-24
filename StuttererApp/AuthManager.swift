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

    @Published private(set) var userID: String?

    // message shown to the user when something goes wrong
    @Published var errorMessage: String?

    // message shown after something worked, like a password reset email
    @Published var infoMessage: String?

    // true while waiting for firebase
    @Published private(set) var isLoading = false

    // false until GoogleService-Info.plist is added to the project
    let isConfigured: Bool

    // keeps the firebase login listener alive
    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        isConfigured = FirebaseApp.app() != nil
        guard isConfigured else { return }

        // firebase has already restored any saved session by the time
        // FirebaseApp.configure() returns, so read it now. without this the
        // login screen flashes on every launch before the listener catches up.
        apply(Auth.auth().currentUser)

        // fires whenever they sign in or out from here on
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.apply(user)
            }
        }
    }

    // stops firebase holding on to the listener after this object goes away
    deinit {
        if let authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }

    // shows a validation error and drops any leftover success message
    private func fail(_ text: String) {
        errorMessage = text
        infoMessage = nil
    }

    // copies the firebase user into the published properties
    private func apply(_ user: User?) {
        isSignedIn = user != nil
        userEmail = user?.email
        userID = user?.uid
    }

    // creates a new account
    func signUp(email: String, password: String, confirmPassword: String) async {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        // checks input before calling firebase
        if let error = AuthValidator.emailError(email)
            ?? AuthValidator.passwordError(password)
            ?? AuthValidator.confirmError(password, confirmPassword) {
            fail(error)
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
            fail(error)
            return
        }
        if password.isEmpty {
            fail("Please enter your password.")
            return
        }

        await run {
            try await Auth.auth().signIn(withEmail: email, password: password)
        }
    }

    // logs the user out
    func signOut() {
        guard isConfigured else { return }

        // otherwise an old error is still on screen at the login page
        errorMessage = nil
        infoMessage = nil

        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = message(for: error)
        }
    }

    // emails a reset link, firebase hosts the page that changes the password
    func resetPassword(email: String) async {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if let error = AuthValidator.emailError(email) {
            fail(error)
            return
        }

        let sent = await run {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        }

        // firebase says nothing about whether the address exists, so that
        // an attacker can't use this to find out who has an account
        if sent {
            infoMessage = "If that email has an account, a reset link is on its way."
        }
    }

    // runs a firebase call with a loading state and friendly errors,
    // returning true when it worked
    @discardableResult
    private func run(_ action: () async throws -> Void) async -> Bool {
        guard isConfigured else {
            errorMessage = "Firebase isn't set up yet. Add GoogleService-Info.plist to the project."
            return false
        }

        errorMessage = nil
        infoMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await action()
            return true
        } catch {
            errorMessage = message(for: error)
            return false
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
        case .invalidRecipientEmail:
            return "Please enter a valid email address."
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
