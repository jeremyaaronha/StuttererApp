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
}
