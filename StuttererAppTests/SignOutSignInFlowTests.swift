//
//  SignOutSignInFlowTests.swift
//  StuttererApp
//

import XCTest
@testable import StuttererApp

@MainActor
final class SignOutSignInFlowTests: XCTestCase {

    func testAudioSettingsSurviveSignOutAndSignInCycle() async {
        let mockAuth = MockAuthService()
        let auth = AuthManager(service: mockAuth, isConfigured: true)

        let testDefaults = UserDefaults(suiteName: "SignOutSignInFlowTests")!
        testDefaults.removePersistentDomain(forName: "SignOutSignInFlowTests")
        defer { testDefaults.removePersistentDomain(forName: "SignOutSignInFlowTests") }

        // sign up, mirroring what happens the first time someone uses the app
        await auth.signUp(email: "rodrigo@example.com", password: "password1", confirmPassword: "password1")
        XCTAssertTrue(auth.isSignedIn)

        // MainTabView.onAppear's loadSettings(for: auth.userID ?? "guest")
        let audio = AudioManager(defaults: testDefaults)
        audio.loadSettings(for: auth.userID ?? "guest")
        audio.delayTime1 = 0.42
        audio.voiceEffect = -8

        auth.signOut()
        XCTAssertFalse(auth.isSignedIn)

        // signs back in as the same account
        await auth.signIn(email: "rodrigo@example.com", password: "password1")
        XCTAssertTrue(auth.isSignedIn)

        // a fresh AudioManager, as MainTabView would create on re-appearing
        let reloadedAudio = AudioManager(defaults: testDefaults)
        reloadedAudio.loadSettings(for: auth.userID ?? "guest")

        XCTAssertEqual(reloadedAudio.delayTime1, 0.42, accuracy: 0.0001)
        XCTAssertEqual(reloadedAudio.voiceEffect, -8)
    }

    func testSettingsDontLeakBetweenDifferentAccounts() async {
        let testDefaults = UserDefaults(suiteName: "SignOutSignInFlowTests2")!
        testDefaults.removePersistentDomain(forName: "SignOutSignInFlowTests2")
        defer { testDefaults.removePersistentDomain(forName: "SignOutSignInFlowTests2") }

        let mockAuth1 = MockAuthService()
        let auth1 = AuthManager(service: mockAuth1, isConfigured: true)
        await auth1.signUp(email: "rodrigo@example.com", password: "password1", confirmPassword: "password1")

        let audio1 = AudioManager(defaults: testDefaults)
        audio1.loadSettings(for: auth1.userID ?? "guest")
        audio1.voice2Volume = 0.15

        auth1.signOut()

        // a different account signs in on the same device
        let mockAuth2 = MockAuthService()
        let auth2 = AuthManager(service: mockAuth2, isConfigured: true)
        await auth2.signUp(email: "someoneelse@example.com", password: "password1", confirmPassword: "password1")

        let audio2 = AudioManager(defaults: testDefaults)
        audio2.loadSettings(for: auth2.userID ?? "guest")

        // should get the built-in default, not rodrigo's 0.15
        XCTAssertEqual(audio2.voice2Volume, 0.7)
    }
}
