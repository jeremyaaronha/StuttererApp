import Foundation
import AVFoundation
import Combine

final class AudioManager: ObservableObject {

    // controls the audio
    private let audioEngine = AVAudioEngine()

    // controls first voice delay
    private let delayNode1 = AVAudioUnitDelay()

    // controls second voice delay
    private let delayNode2 = AVAudioUnitDelay()

    // changes the second voice
    private let voiceEQ = AVAudioUnitEQ(numberOfBands: 4)

    // controls second voice volume
    private let voice2Mixer = AVAudioMixerNode()

    // ranges the sliders are drawn with, kept here so a stored value can
    // never fall outside the track the user sees
    static let delayRange: ClosedRange<Double> = 0...0.5
    static let voiceEffectRange: ClosedRange<Float> = -20...20
    static let voice2VolumeRange: ClosedRange<Float> = 0...1

    // first voice delay
    @Published var delayTime1: Double = 0.25 {
        didSet {
            delayNode1.delayTime = delayTime1
        }
    }

    // second voice delay
    @Published var delayTime2: Double = 0.30 {
        didSet {
            delayNode2.delayTime = delayTime2
        }
    }
    // voice effect value
    @Published var voiceEffect: Float = 0 {
        didSet {
            updateVoiceEffect()
        }
    }

    // second voice volume
    @Published var voice2Volume: Float = 0.7 {
        didSet {
            voice2Mixer.volume = voice2Volume
        }
    }

    // audio status
    @Published var isRunning = false
    
    // current user settings
    private var userID: String?

    init() {
        configureSession()
        configureEQ()
        configureEngine()
    }
    
    // loads saved audio settings for the current user
    func loadSettings(for userID: String) {

        self.userID = userID

        let defaults = UserDefaults.standard


        if defaults.object(forKey: delayTime1Key) != nil {
            delayTime1 = defaults.double(forKey: delayTime1Key)
                .clamped(to: Self.delayRange)
        }


        if defaults.object(forKey: delayTime2Key) != nil {
            delayTime2 = defaults.double(forKey: delayTime2Key)
                .clamped(to: Self.delayRange)
        }


        if defaults.object(forKey: voiceEffectKey) != nil {
            voiceEffect = defaults.float(forKey: voiceEffectKey)
                .clamped(to: Self.voiceEffectRange)
        }


        if defaults.object(forKey: voice2VolumeKey) != nil {
            voice2Volume = defaults.float(forKey: voice2VolumeKey)
                .clamped(to: Self.voice2VolumeRange)
        }
    }



    // saves audio settings. called when a slider drag ends, on reset, and
    // when the app leaves the foreground, rather than from the didSet blocks
    // above, which would write on every frame of a drag. does nothing until
    // loadSettings has said who is signed in.
    func saveSettings() {

        guard userID != nil else {
            return
        }


        let defaults = UserDefaults.standard


        defaults.set(
            delayTime1,
            forKey: delayTime1Key
        )


        defaults.set(
            delayTime2,
            forKey: delayTime2Key
        )


        defaults.set(
            voiceEffect,
            forKey: voiceEffectKey
        )


        defaults.set(
            voice2Volume,
            forKey: voice2VolumeKey
        )
    }
    
    private var delayTime1Key: String {
        "delayTime1_\(userID ?? "guest")"
    }


    private var delayTime2Key: String {
        "delayTime2_\(userID ?? "guest")"
    }


    private var voiceEffectKey: String {
        "voiceEffect_\(userID ?? "guest")"
    }


    private var voice2VolumeKey: String {
        "voice2Volume_\(userID ?? "guest")"
    }

    private func configureSession() {

        // gets the audio session
        let session = AVAudioSession.sharedInstance()

        do {

            // configures input and output
            try session.setCategory(
                .playAndRecord,
                mode: .default,
                options: [
                    .allowBluetooth,
                    .allowBluetoothA2DP,
                    .defaultToSpeaker
                ]
            )

            // starts the audio session
            try session.setActive(true)

        } catch {
            print("Session error: \(error)")
        }
    }

    private func configureEQ() {

        // controls bass
        let bass = voiceEQ.bands[0]
        bass.filterType = .lowShelf
        bass.frequency = 180
        bass.bandwidth = 0.5
        bass.gain = 0
        bass.bypass = false

        // controls low mids
        let lowMid = voiceEQ.bands[1]
        lowMid.filterType = .parametric
        lowMid.frequency = 500
        lowMid.bandwidth = 1.0
        lowMid.gain = 0
        lowMid.bypass = false

        // controls voice presence
        let presence = voiceEQ.bands[2]
        presence.filterType = .parametric
        presence.frequency = 2200
        presence.bandwidth = 1.0
        presence.gain = 0
        presence.bypass = false

        // controls high sounds
        let treble = voiceEQ.bands[3]
        treble.filterType = .highShelf
        treble.frequency = 4000
        treble.bandwidth = 0.5
        treble.gain = 0
        treble.bypass = false

        updateVoiceEffect()
    }

    private func updateVoiceEffect() {

        // converts slider to -1 and 1
        let amount = max(-1, min(1, voiceEffect / 20))

        // gets effect strength
        let strength = abs(amount)

        if amount < 0 {

            // makes second voice darker
            voiceEQ.bands[0].gain = strength * 20
            voiceEQ.bands[1].gain = strength * 14
            voiceEQ.bands[2].gain = -strength * 14
            voiceEQ.bands[3].gain = -strength * 20

        } else {

            // makes second voice brighter
            voiceEQ.bands[0].gain = -strength * 20
            voiceEQ.bands[1].gain = -strength * 14
            voiceEQ.bands[2].gain = strength * 14
            voiceEQ.bands[3].gain = strength * 20
        }
    }

    private func configureEngine() {

        // gets microphone input
        let input = audioEngine.inputNode

        // gets microphone format
        let format = input.outputFormat(forBus: 0)

        // checks the format
        guard format.sampleRate > 0,
              format.channelCount > 0 else {
            print("Invalid microphone format")
            return
        }

        // adds audio nodes
        audioEngine.attach(delayNode1)
        audioEngine.attach(delayNode2)
        audioEngine.attach(voiceEQ)
        audioEngine.attach(voice2Mixer)

        // configures first delay
        delayNode1.delayTime = delayTime1
        delayNode1.feedback = 0
        delayNode1.wetDryMix = 100

        // configures second delay
        delayNode2.delayTime = delayTime2
        delayNode2.feedback = 0
        delayNode2.wetDryMix = 100

        // sets second voice volume
        voice2Mixer.volume = voice2Volume

        // creates both voice paths
        let voice1 = AVAudioConnectionPoint(
            node: delayNode1,
            bus: 0
        )

        let voice2 = AVAudioConnectionPoint(
            node: delayNode2,
            bus: 0
        )

        // sends microphone to both voices
        audioEngine.connect(
            input,
            to: [voice1, voice2],
            fromBus: 0,
            format: format
        )

        // sends first voice to output
        audioEngine.connect(
            delayNode1,
            to: audioEngine.mainMixerNode,
            format: format
        )

        // sends second voice to effect
        audioEngine.connect(
            delayNode2,
            to: voiceEQ,
            format: format
        )

        // sends second voice to volume
        audioEngine.connect(
            voiceEQ,
            to: voice2Mixer,
            format: format
        )

        // sends second voice to output
        audioEngine.connect(
            voice2Mixer,
            to: audioEngine.mainMixerNode,
            format: format
        )

        // prepares the audio
        audioEngine.prepare()
    }

    func toggleAudio() {

        // stops the audio
        if audioEngine.isRunning {

            audioEngine.stop()
            isRunning = false

        } else {

            do {

                // starts the audio
                try audioEngine.start()
                isRunning = true

                print("Audio engine started")

            } catch {

                print("Engine start error: \(error)")
                isRunning = false
            }
        }
    }

    func resetSettings() {

        // resets the values
        delayTime1 = 0.25
        delayTime2 = 0.30
        voiceEffect = 0
        voice2Volume = 0.7

        // the didSet blocks no longer save, so the reset has to say so itself
        saveSettings()
    }
}

// keeps a value that came back from storage inside the range the UI expects
private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
