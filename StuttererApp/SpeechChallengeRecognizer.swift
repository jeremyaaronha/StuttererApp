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
// supports english and spanish speech exercises
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

    // created for the language of each challenge
    private var recognizer: SFSpeechRecognizer?

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
    func start(
        prompt: String,
        patterns: [String],
        language: String = "en-US"
    ) {

        // select the recognition language
        recognizer = SFSpeechRecognizer(
            locale: Locale(identifier: language)
        )

        guard let recognizer, recognizer.isAvailable else {
            errorMessage = "Speech recognition is not available right now."
            return
        }

        // reset state for a fresh attempt
        transcript = ""
        lastResult = nil
        errorMessage = nil

        targetWords = SpeechChallenge.targetWords(
            in: prompt,
            patterns: patterns
        )
        .map { $0.lowercased() }

        // configure the session for recording
        do {
            let session = AVAudioSession.sharedInstance()

            // allowBluetooth supports compatible bluetooth microphones
            try session.setCategory(
                .playAndRecord,
                mode: .default,
                options: [
                    .duckOthers,
                    .defaultToSpeaker,
                    .allowBluetooth
                ]
            )

            try session.setActive(
                true,
                options: .notifyOthersOnDeactivation
            )

        } catch {
            errorMessage = "Could not start the microphone."
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        // allow server recognition when on-device is unavailable
        request.requiresOnDeviceRecognition = false

        self.request = request

        // use a fresh engine for the current microphone format
        audioEngine = AVAudioEngine()

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)

        guard format.sampleRate > 0,
              format.channelCount > 0 else {

            errorMessage = "The microphone is not ready yet. Please try again."
            return
        }

        input.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: nil
        ) { [weak self] buffer, _ in
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

        task = recognizer.recognitionTask(
            with: request
        ) { [weak self] result, error in

            Task { @MainActor in

                if let result {
                    self?.transcript =
                        result.bestTranscription.formattedString
                }

                if let error {
                    print(
                        "Speech recognition error: \(error.localizedDescription)"
                    )

                    self?.errorMessage =
                        "Recognition error: \(error.localizedDescription)"
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
            .setActive(
                false,
                options: .notifyOthersOnDeactivation
            )

        let result = Self.evaluate(
            transcript: transcript,
            targetWords: targetWords
        )

        lastResult = result

        return result
    }

    // scores the transcript against the expected target words
    private static func evaluate(
        transcript: String,
        targetWords: [String]
    ) -> ChallengeResult {

        let spokenWords = transcript
            .lowercased()
            .split { !$0.isLetter }
            .map { String($0) }

        let spokenSet = Set(spokenWords)

        let matched = targetWords.filter {
            spokenSet.contains($0)
        }

        // count immediate word repetitions
        var repetitions = 0

        for index in 1..<max(spokenWords.count, 1)
        where index < spokenWords.count {

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
