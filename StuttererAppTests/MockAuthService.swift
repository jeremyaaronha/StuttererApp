//
//  MockAuthService.swift
//  StuttererApp
//
import Foundation
@testable import StuttererApp

final class MockAuthService: AuthServicing {
    var currentUser: AuthUser?

    var createUserError: Error?
    var signInError: Error?
    var signOutError: Error?

    private(set) var createUserCalled = false
    private(set) var signInCalled = false
    private(set) var signOutCalled = false

    private var onChange: ((AuthUser?) -> Void)?

    func createUser(email: String, password: String) async throws {
        createUserCalled = true
        if let createUserError { throw createUserError }
        // derives a stable per-email uid, instead of reusing the same one
        // for every account, so different mock accounts behave like different
        // real accounts would
        currentUser = AuthUser(uid: "mock-uid-\(email)", email: email)
        onChange?(currentUser)
    }

    func signIn(email: String, password: String) async throws {
        signInCalled = true
        if let signInError { throw signInError }
        currentUser = AuthUser(uid: "mock-uid-\(email)", email: email)
        onChange?(currentUser)
    }

    func signOut() throws {
        signOutCalled = true
        currentUser = nil
        onChange?(nil)
    }

    func sendPasswordReset(email: String) async throws {}

    func listen(onChange: @escaping (AuthUser?) -> Void) {
        self.onChange = onChange
    }

    func stopListening() {
        onChange = nil
    }
}
