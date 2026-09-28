import Foundation
import Combine
import Speech
import AVFoundation

// the outcome of a recorded challenge attempt
struct ChallengeResult {
    let matchedTargets: [String]
    let totalTargets: Int
    let repetitions: Int

    // fraction of target sound words that were recognized
    var accuracy: Double {
        guard totalTargets > 0 else { return 0 }
        return Double(matchedTargets.count) / Double(totalTargets)
    }

    // a pass needs most target words recognized
    var passed: Bool {
        accuracy >= 0.7
    }
}

// live speech recognition for challenges
// listens to the microphone, transcribes on device, and scores which target
// sound words were spoken. it also flags obvious word repetitions as a simple
// disfluency hint. this is guidance, not a clinical stutter diagnosis.
@MainActor
final class SpeechChallengeRecognizer: ObservableObject {

    // what the recognizer has heard so far
    @Published var transcript: String = ""

    // whether the microphone is currently listening
    @Published var isRecording = false

    // set when the user has not granted speech or microphone permission
    @Published var authorizationDenied = false

    // any user facing error message
    @Published var errorMessage: String?

    // the score from the most recent attempt
    @Published var lastResult: ChallengeResult?

    private var audioEngine = AVAudioEngine()
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    private var targetWords: [String] = []

    // asks for speech recognition and microphone permission
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] speechStatus in
            AVAudioApplication.requestRecordPermission { micGranted in
                Task { @MainActor in
                    let speechGranted = speechStatus == .authorized
                    self?.authorizationDenied = !(speechGranted && micGranted)
                }
            }
        }
    }

    // begins listening and prepares to score the given prompt
    func start(prompt: String, patterns: [String]) {

        guard let recognizer, recognizer.isAvailable else {
            errorMessage = "Speech recognition is not available right now."
            return
        }

        // reset state for a fresh attempt
        transcript = ""
        lastResult = nil
        errorMessage = nil
        targetWords = SpeechChallenge.targetWords(in: prompt, patterns: patterns)
            .map { $0.lowercased() }

        // configure the session for recording
        do {
            let session = AVAudioSession.sharedInstance()
            // allowBluetoothHFP lets a paired Bluetooth headset act as the mic input
            try session.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.duckOthers, .defaultToSpeaker, .allowBluetoothHFP]
            )
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Could not start the microphone."
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        // keep everything on device when the phone supports it
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        self.request = request

        // a fresh engine picks up the current hardware input format, avoiding a
        // stale-format tap mismatch that can crash after the session sample rate changes
        audioEngine = AVAudioEngine()
        let input = audioEngine.inputNode

        // read the live input format only after the session is active
        let format = input.outputFormat(forBus: 0)

        // the mic format can briefly be invalid; bail gracefully instead of crashing
        guard format.sampleRate > 0, format.channelCount > 0 else {
            errorMessage = "The microphone is not ready yet. Please try again."
            return
        }

        // passing nil uses the node's own bus format, so the tap can never mismatch
        input.installTap(onBus: 0, bufferSize: 1024, format: nil) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            input.removeTap(onBus: 0)
            errorMessage = "Could not start audio."
            return
        }

        isRecording = true

        task = recognizer.recognitionTask(with: request) { [weak self] result, _ in
            Task { @MainActor in
                if let result {
                    self?.transcript = result.bestTranscription.formattedString
                }
            }
        }
    }

    // stops listening and returns the scored result
    @discardableResult
    func stop() -> ChallengeResult {

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        isRecording = false

        try? AVAudioSession.sharedInstance()
            .setActive(false, options: .notifyOthersOnDeactivation)

        let result = Self.evaluate(transcript: transcript, targetWords: targetWords)
        lastResult = result
        return result
    }

    // scores the transcript against the expected target words
    private static func evaluate(transcript: String, targetWords: [String]) -> ChallengeResult {

        let spokenWords = transcript
            .lowercased()
            .split { !$0.isLetter }
            .map { String($0) }

        let spokenSet = Set(spokenWords)

        let matched = targetWords.filter { spokenSet.contains($0) }

        // count immediate word repetitions as a simple disfluency hint
        var repetitions = 0
        for index in 1..<max(spokenWords.count, 1) where index < spokenWords.count {
            if spokenWords[index] == spokenWords[index - 1] {
                repetitions += 1
            }
        }

        return ChallengeResult(
            matchedTargets: matched,
            totalTargets: targetWords.count,
            repetitions: repetitions
        )
    }
}
