import Foundation
import AVFoundation
import Combine

class AudioManager: ObservableObject {

    // controls the audio system
    private let audioEngine = AVAudioEngine()

    // adds delay to the voice
    private let delayNode = AVAudioUnitDelay()

    // changes the voice tone
    private let eqNode = AVAudioUnitEQ(numberOfBands: 2)

    @Published var delayTime: Double = 0.1 {
        didSet {
            // updates the delay time
            delayNode.delayTime = delayTime
            saveSettings()
        }
    }

    @Published var toneAmount: Float = 0 {
        didSet {
            // updates the voice tone
            updateEQ()
            saveSettings()
        }
    }

    // shows if the audio is active
    @Published var isRunning: Bool = false

    // whose settings are currently loaded, nil until loadSettings is called
    private var userID: String?

    // stops the didSet above from saving while we're reading saved values in
    private var isLoadingSettings = false

    init() {
        // starts audio settings
        configureSession()

        // creates audio connections
        configureEngine()
    }

    // call this once, right when the signed-in user is known, e.g. from
    // ContentView's onAppear. loads that account's saved delay and tone,
    // or leaves the defaults in place if nothing was saved yet.
    func loadSettings(for userID: String) {
        self.userID = userID
        isLoadingSettings = true

        let defaults = UserDefaults.standard
        if defaults.object(forKey: delayKey) != nil {
            delayTime = defaults.double(forKey: delayKey)
        }
        if defaults.object(forKey: toneKey) != nil {
            toneAmount = defaults.float(forKey: toneKey)
        }

        isLoadingSettings = false
    }

    // per-account storage keys, "guest" is just a fallback and shouldn't
    // normally show up since ContentView only appears when signed in
    private var delayKey: String { "delayTime_\(userID ?? "guest")" }
    private var toneKey: String { "toneAmount_\(userID ?? "guest")" }

    // writes the current values to disk, skipped while loadSettings is
    // still filling them in, so it doesn't immediately overwrite what
    // was just read
    private func saveSettings() {
        guard !isLoadingSettings, let userID else { return }
        let defaults = UserDefaults.standard
        defaults.set(delayTime, forKey: delayKey)
        defaults.set(toneAmount, forKey: toneKey)
    }

    private func configureSession() {
        // gets the iphone audio session
        let session = AVAudioSession.sharedInstance()
        do {
            // allows microphone and headphones
            try session.setCategory(.playAndRecord,
                                    mode: .voiceChat,
                                    options: [.allowBluetooth,
                                              .allowBluetoothA2DP,
                                              .defaultToSpeaker])

            // activates the audio
            try session.setActive(true)
        } catch {
            print("Session error: \(error)")
        }
    }

    private func configureEngine() {

        // gets microphone input
        let input = audioEngine.inputNode

        // gets audio format
        let format = input.outputFormat(forBus: 0)

        // adds audio effects
        audioEngine.attach(delayNode)
        audioEngine.attach(eqNode)

        // configures delay effect
        delayNode.feedback = 0
        delayNode.wetDryMix = 100

        // creates tone settings
        setupEQ()

        // connects microphone to delay
        audioEngine.connect(input,
                            to: delayNode,
                            format: format)

        // connects delay to tone effect
        audioEngine.connect(delayNode,
                            to: eqNode,
                            format: format)

        // sends audio to headphones
        audioEngine.connect(eqNode,
                            to: audioEngine.mainMixerNode,
                            format: format)

        // prepares audio engine
        audioEngine.prepare()
    }

    private func setupEQ() {

        // controls low voice frequencies
        let lowBand = eqNode.bands[0]
        lowBand.filterType = .lowShelf
        lowBand.frequency = 200
        lowBand.bandwidth = 0.5
        lowBand.gain = 0
        lowBand.bypass = false

        // controls high voice frequencies
        let highBand = eqNode.bands[1]
        highBand.filterType = .highShelf
        highBand.frequency = 3000
        highBand.bandwidth = 0.5
        highBand.gain = 0
        highBand.bypass = false
    }

    private func updateEQ() {

        // changes voice tone

        eqNode.bands[0].gain = toneAmount      // low sounds
        eqNode.bands[1].gain = -toneAmount     // high sounds
    }

    func toggleAudio() {

        // stops audio if it is running
        if audioEngine.isRunning {
            audioEngine.stop()
            isRunning = false
        } else {
            do {
                // starts live audio processing
                try audioEngine.start()
                isRunning = true
            } catch {
                print("Engine start error: \(error)")
            }
        }
    }
}
