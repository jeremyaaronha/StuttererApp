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
        // updates the delay time
        didSet { delayNode.delayTime = delayTime }
    }

    @Published var toneAmount: Float = 0 {
        // updates the voice tone
        didSet { updateEQ() }
    }

    // shows if the audio is active
    @Published var isRunning: Bool = false

    init() {
        // starts audio settings
        configureSession()
        
        // creates audio connections
        configureEngine()
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
