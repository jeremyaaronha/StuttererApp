//
//  AuthManagerTests.swift
//  StuttererApp

import XCTest
@testable import StuttererApp

@MainActor
final class AuthManagerTests: XCTestCase {

    func testSignUpWithInvalidEmailDoesNotCallService() async {
        let mock = MockAuthService()
        let manager = AuthManager(service: mock, isConfigured: true)

        await manager.signUp(email: "not-an-email", password: "password1", confirmPassword: "password1")

        XCTAssertFalse(mock.createUserCalled)
        XCTAssertNotNil(manager.errorMessage)
    }

    func testSignUpWithMismatchedPasswordsDoesNotCallService() async {
        let mock = MockAuthService()
        let manager = AuthManager(service: mock, isConfigured: true)

        await manager.signUp(email: "rodrigo@example.com", password: "password1", confirmPassword: "password2")

        XCTAssertFalse(mock.createUserCalled)
        XCTAssertEqual(manager.errorMessage, "Passwords do not match.")
    }

    func testSignUpSuccessUpdatesSignedInState() async {
        let mock = MockAuthService()
        let manager = AuthManager(service: mock, isConfigured: true)

        await manager.signUp(email: "rodrigo@example.com", password: "password1", confirmPassword: "password1")

        XCTAssertTrue(mock.createUserCalled)
        XCTAssertTrue(manager.isSignedIn)
        XCTAssertEqual(manager.userEmail, "rodrigo@example.com")
    }

    func testSignOutClearsSignedInState() async {
        let mock = MockAuthService()
        let manager = AuthManager(service: mock, isConfigured: true)
        await manager.signUp(email: "rodrigo@example.com", password: "password1", confirmPassword: "password1")

        manager.signOut()

        XCTAssertTrue(mock.signOutCalled)
        XCTAssertFalse(manager.isSignedIn)
        XCTAssertNil(manager.userEmail)
    }

    func testNotConfiguredShowsConfigurationError() async {
        let mock = MockAuthService()
        let manager = AuthManager(service: mock, isConfigured: false)

        await manager.signIn(email: "rodrigo@example.com", password: "password1")

        XCTAssertFalse(mock.signInCalled)
        XCTAssertEqual(manager.errorMessage, "Firebase isn't set up yet. Add GoogleService-Info.plist to the project.")
    }
}
