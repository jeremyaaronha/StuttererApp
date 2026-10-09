//
//  AudioManagerTests.swift
//  StuttererApp

import XCTest
@testable import StuttererApp

final class AudioManagerTests: XCTestCase {

    var testDefaults: UserDefaults!
    var audioManager: AudioManager!

    override func setUp() {
        super.setUp()
        // isolated suite so these tests never touch real saved settings
        testDefaults = UserDefaults(suiteName: "AudioManagerTests")
        testDefaults.removePersistentDomain(forName: "AudioManagerTests")
        audioManager = AudioManager(defaults: testDefaults)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: "AudioManagerTests")
        audioManager = nil
        testDefaults = nil
        super.tearDown()
    }

    func testResetSettingsRestoresDefaults() {
        audioManager.delayTime1 = 0.4
        audioManager.delayTime2 = 0.1
        audioManager.voiceEffect = 15
        audioManager.voice2Volume = 0.2

        audioManager.resetSettings()

        XCTAssertEqual(audioManager.delayTime1, 0.25)
        XCTAssertEqual(audioManager.delayTime2, 0.30)
        XCTAssertEqual(audioManager.voiceEffect, 0)
        XCTAssertEqual(audioManager.voice2Volume, 0.7)
    }

    func testSettingsPersistPerUser() {
        audioManager.loadSettings(for: "user123")
        audioManager.delayTime1 = 0.4
        audioManager.voiceEffect = 12

        // simulates relaunch: fresh AudioManager, same defaults suite
        let reloaded = AudioManager(defaults: testDefaults)
        reloaded.loadSettings(for: "user123")

        XCTAssertEqual(reloaded.delayTime1, 0.4)
        XCTAssertEqual(reloaded.voiceEffect, 12)
    }

    func testDifferentUsersDontShareSettings() {
        audioManager.loadSettings(for: "userA")
        audioManager.delayTime1 = 0.05

        let other = AudioManager(defaults: testDefaults)
        other.loadSettings(for: "userB")

        // userB has never saved anything, so it should keep the built-in default
        XCTAssertEqual(other.delayTime1, 0.25)
    }
    
    // MARK: - Boundary values

    func testDelayTimeAtMinimumBoundary() {
        audioManager.delayTime1 = 0.0
        XCTAssertEqual(audioManager.delayTime1, 0.0)
    }

    func testDelayTimeAtMaximumBoundary() {
        audioManager.delayTime1 = 0.5
        XCTAssertEqual(audioManager.delayTime1, 0.5)
    }

    func testVoiceEffectAtMinimumBoundary() {
        audioManager.voiceEffect = -20
        XCTAssertEqual(audioManager.voiceEffect, -20)
    }

    func testVoiceEffectAtMaximumBoundary() {
        audioManager.voiceEffect = 20
        XCTAssertEqual(audioManager.voiceEffect, 20)
    }

    func testVoiceEffectAtZeroIsNeutral() {
        // zero should mean no coloring applied either direction
        audioManager.voiceEffect = 0
        XCTAssertEqual(audioManager.voiceEffect, 0)
    }

    func testVoice2VolumeAtMinimumBoundary() {
        audioManager.voice2Volume = 0.0
        XCTAssertEqual(audioManager.voice2Volume, 0.0)
    }

    func testVoice2VolumeAtMaximumBoundary() {
        audioManager.voice2Volume = 1.0
        XCTAssertEqual(audioManager.voice2Volume, 1.0)
    }

    // MARK: - Rapid consecutive changes

    func testRapidSliderChangesKeepLastValue() {
        audioManager.loadSettings(for: "user123")

        // simulates someone dragging a slider quickly
        for value in stride(from: 0.0, through: 0.5, by: 0.05) {
            audioManager.delayTime1 = value
        }

        XCTAssertEqual(audioManager.delayTime1, 0.5, accuracy: 0.0001)

        // confirms the last value, not an intermediate one, is what got saved
        let reloaded = AudioManager(defaults: testDefaults)
        reloaded.loadSettings(for: "user123")
        XCTAssertEqual(reloaded.delayTime1, 0.5, accuracy: 0.0001)
    }

    func testChangingAllFourSlidersSavesAllFour() {
        audioManager.loadSettings(for: "user123")

        audioManager.delayTime1 = 0.4
        audioManager.delayTime2 = 0.1
        audioManager.voiceEffect = -15
        audioManager.voice2Volume = 0.3

        let reloaded = AudioManager(defaults: testDefaults)
        reloaded.loadSettings(for: "user123")

        XCTAssertEqual(reloaded.delayTime1, 0.4, accuracy: 0.0001)
        XCTAssertEqual(reloaded.delayTime2, 0.1, accuracy: 0.0001)
        XCTAssertEqual(reloaded.voiceEffect, -15)
        XCTAssertEqual(reloaded.voice2Volume, 0.3, accuracy: 0.0001)
    }

    // MARK: - Guest fallback

    func testGuestFallbackDoesNotCrashWhenNoUserID() {
        // mirrors ContentView's auth.userID ?? "guest" pattern
        audioManager.loadSettings(for: "guest")
        audioManager.delayTime1 = 0.2

        let reloaded = AudioManager(defaults: testDefaults)
        reloaded.loadSettings(for: "guest")

        XCTAssertEqual(reloaded.delayTime1, 0.2, accuracy: 0.0001)
    }

    func testGuestAndRealUserDontShareSettings() {
        audioManager.loadSettings(for: "guest")
        audioManager.delayTime1 = 0.45

        let realUser = AudioManager(defaults: testDefaults)
        realUser.loadSettings(for: "user123")

        // a real account should never inherit whatever "guest" left behind
        XCTAssertEqual(realUser.delayTime1, 0.25)
    }
}
