//
//  AuthManager.swift
//  StuttererApp
//

//
//  AuthManager.swift
//  StuttererApp
//

import Foundation
import Combine
import FirebaseCore
import FirebaseAuth

@MainActor
final class AuthManager: ObservableObject {

    @Published private(set) var isSignedIn = false
    @Published private(set) var userEmail: String?
    @Published private(set) var userID: String?
    @Published var errorMessage: String?
    @Published var infoMessage: String?
    @Published private(set) var isLoading = false

    let isConfigured: Bool
    private let service: AuthServicing

    init(service: AuthServicing = FirebaseAuthService(),
         isConfigured: Bool = FirebaseApp.app() != nil) {
        self.service = service
        self.isConfigured = isConfigured
        guard isConfigured else { return }

        apply(service.currentUser)

        service.listen { [weak self] user in
            Task { @MainActor in
                self?.apply(user)
            }
        }
    }

    deinit {
        service.stopListening()
    }

    private func fail(_ text: String) {
        errorMessage = text
        infoMessage = nil
    }

    private func apply(_ user: AuthUser?) {
        isSignedIn = user != nil
        userEmail = user?.email
        userID = user?.uid
    }

    func signUp(email: String, password: String, confirmPassword: String) async {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPassword = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        if let error = AuthValidator.emailError(email)
            ?? AuthValidator.passwordError(password)
            ?? AuthValidator.confirmError(password, confirmPassword) {
            fail(error)
            return
        }

        let success = await run {
            try await self.service.createUser(email: email, password: password)
        }
        if success {
            apply(service.currentUser)
        }
    }

    func signIn(email: String, password: String) async {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if let error = AuthValidator.emailError(email) {
            fail(error)
            return
        }
        if password.isEmpty {
            fail("Please enter your password.")
            return
        }

        let success = await run {
            try await self.service.signIn(email: email, password: password)
        }
        if success {
            apply(service.currentUser)
        }
    }

    func signOut() {
        guard isConfigured else { return }
        errorMessage = nil
        infoMessage = nil
        do {
            try service.signOut()
            apply(nil)
        } catch {
            errorMessage = message(for: error)
        }
    }

    func resetPassword(email: String) async {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if let error = AuthValidator.emailError(email) {
            fail(error)
            return
        }
        let sent = await run {
            try await self.service.sendPasswordReset(email: email)
        }
        if sent {
            infoMessage = "If that email has an account, a reset link is on its way."
        }
    }

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
