import SwiftUI
import AVFoundation

// texts library tab
struct TextsView: View {

    @EnvironmentObject private var auth: AuthManager
    @StateObject private var store = PracticeTextStore()

    @State private var showingNewText = false
    @State private var selectedText: PracticeText?

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    ScreenHeader(
                        title: "Texts",
                        subtitle: "TEXTS LIBRARY"
                    )

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {

                            Text("Speech Reader Input")
                                .font(.headline)

                            Text("Create and save texts to use during your practice sessions.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Button {
                                showingNewText = true
                            } label: {
                                Label(
                                    "New Practice Text",
                                    systemImage: "plus"
                                )
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .appearCard()

                    VStack(alignment: .leading, spacing: 8) {

                        Text("My Saved Practice Texts")
                            .font(.headline)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )

                        if store.texts.isEmpty {

                            GlassCard {
                                VStack(spacing: 8) {
                                    Image(systemName: "doc.text")
                                        .font(.title2)
                                        .foregroundColor(.secondary)

                                    Text("No saved texts yet")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }

                        } else {

                            ForEach(store.texts) { item in

                                Button {
                                    selectedText = item
                                } label: {
                                    GlassCard {
                                        HStack {

                                            VStack(
                                                alignment: .leading,
                                                spacing: 4
                                            ) {
                                                Text(item.title)
                                                    .font(
                                                        .subheadline
                                                            .weight(.semibold)
                                                    )

                                                Text(textInfo(item))
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }

                                            Spacer()

                                            Image(
                                                systemName: "chevron.right"
                                            )
                                            .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .buttonStyle(PressableButtonStyle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteText(item)
                                    } label: {
                                        Label(
                                            "Delete",
                                            systemImage: "trash"
                                        )
                                    }
                                }
                            }
                        }

                        if let errorMessage = store.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(24)
            }
        }
        .onAppear {
            if let userID = auth.userID {
                store.startListening(userID: userID)
            }
        }
        .onDisappear {
            store.stopListening()
        }
        .sheet(isPresented: $showingNewText) {
            TextEditorView(store: store)
                .environmentObject(auth)
        }
        .sheet(item: $selectedText) { text in
            PracticeTextDetailView(
                store: store,
                text: text
            )
            .environmentObject(auth)
        }
    }

    // shows basic information about the text
    private func textInfo(_ text: PracticeText) -> String {

        let words = text.content
            .split { $0.isWhitespace }
            .count

        return "\(words) words"
    }

    // deletes a practice text
    private func deleteText(_ text: PracticeText) {

        guard let userID = auth.userID else {
            return
        }

        Task {
            await store.deleteText(
                userID: userID,
                textID: text.id
            )
        }
    }
}

// controls speech events
final class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {

    var onFinish: (() -> Void)?

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        onFinish?()
    }
}

// shows a saved practice text
struct PracticeTextDetailView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var auth: AuthManager

    @ObservedObject var store: PracticeTextStore

    let text: PracticeText
    
    private var currentText: PracticeText {
        store.texts.first { $0.id == text.id } ?? text
    }

    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var speechRate: Float = 0.5
    @State private var selectedVoiceIdentifier = ""
    @State private var speechParts: [String] = []
    @State private var currentSpeechPart = 0
    @State private var isReading = false
    @State private var speechDelegate = SpeechDelegate()

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        Text(currentText.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        // edit and delete actions
                        HStack(spacing: 12) {

                            Button {
                                showingEdit = true
                            } label: {
                                Label(
                                    "Edit Text",
                                    systemImage: "pencil"
                                )
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)

                            Button(role: .destructive) {
                                showingDeleteAlert = true
                            } label: {
                                Label(
                                    "Delete Text",
                                    systemImage: "trash"
                                )
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }

                        // practice text
                        GlassCard {
                            Text(currentText.content)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 190)
                }

                // fixed text to speech player
                VStack {
                    Spacer()

                    VStack(spacing: 12) {

                        HStack {
                            VStack(
                                alignment: .leading,
                                spacing: 2
                            ) {
                                Text("Text to Speech")
                                    .font(.headline)

                                Text(
                                    isReading
                                    ? "Reading practice text"
                                    : "Ready to read"
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(
                                String(
                                    format: "%.2fx",
                                    speechRate
                                )
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }

                        HStack {

                            Picker(
                                "Voice",
                                selection: $selectedVoiceIdentifier
                            ) {
                                ForEach(
                                    availableVoices,
                                    id: \.identifier
                                ) { voice in

                                    Text(voice.name)
                                        .tag(voice.identifier)
                                }
                            }
                            .pickerStyle(.menu)

                            Spacer()

                            Slider(
                                value: $speechRate,
                                in: 0.1...0.7,
                                step: 0.05
                            )
                            .frame(maxWidth: 140)
                        }

                        HStack(spacing: 20) {

                            Button {
                                stopText()
                            } label: {
                                Image(
                                    systemName: "stop.fill"
                                )
                            }

                            Spacer()

                            Button {
                                playText()
                            } label: {
                                Image(
                                    systemName: "play.fill"
                                )
                                .font(.title2)
                            }

                            Spacer()

                            Button {
                                pauseText()
                            } label: {
                                Image(
                                    systemName: "pause.fill"
                                )
                            }
                        }
                        .font(.headline)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 24
                        )
                        .fill(
                            Color(
                                red: 0.06,
                                green: 0.10,
                                blue: 0.15
                            )
                        )
                    )
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 24
                        )
                        .stroke(
                            Color.white.opacity(0.12),
                            lineWidth: 1
                        )
                    )
                    .shadow(radius: 8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("Practice Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .navigationBarTrailing
                ) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if selectedVoiceIdentifier.isEmpty {
                    selectedVoiceIdentifier =
                        defaultVoiceIdentifier
                }
            }
            .onDisappear {
                stopText()
            }
        }
        .sheet(isPresented: $showingEdit) {
            TextEditorView(
                store: store,
                text: currentText
            )
            .environmentObject(auth)
        }
        .alert(
            "Delete Text",
            isPresented: $showingDeleteAlert
        ) {
            Button(
                "Cancel",
                role: .cancel
            ) { }

            Button(
                "Delete",
                role: .destructive
            ) {
                deleteText()
            }
        } message: {
            Text(
                "Are you sure you want to delete this text?"
            )
        }
    }

    // voices available on the device
    private var availableVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter {
                $0.language.hasPrefix("en")
            }
            .sorted {
                $0.name < $1.name
            }
    }

    private var defaultVoiceIdentifier: String {
        AVSpeechSynthesisVoice(
            language: "en-US"
        )?.identifier
            ?? availableVoices.first?.identifier
            ?? ""
    }

    // starts or continues reading
    private func playText() {

        if speechSynthesizer.isPaused {
            speechSynthesizer.continueSpeaking()
            return
        }

        if speechSynthesizer.isSpeaking {
            return
        }

        if !isReading {
            speechParts = splitText(
                currentText.content
            )

            currentSpeechPart = 0
            isReading = true

            speechDelegate.onFinish = {
                playNextPart()
            }

            speechSynthesizer.delegate =
                speechDelegate
        }

        playCurrentPart()
    }

    // separates the text into small parts
    private func splitText(
        _ text: String
    ) -> [String] {

        text
            .components(
                separatedBy: CharacterSet(
                    charactersIn: ".!?"
                )
            )
            .map {
                $0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }
            .filter {
                !$0.isEmpty
            }
    }

    // reads the current part
    private func playCurrentPart() {

        guard currentSpeechPart <
                speechParts.count else {

            isReading = false
            currentSpeechPart = 0
            return
        }

        let utterance =
            AVSpeechUtterance(
                string:
                    speechParts[
                        currentSpeechPart
                    ]
            )

        utterance.rate = speechRate

        if !selectedVoiceIdentifier.isEmpty {

            utterance.voice =
                AVSpeechSynthesisVoice(
                    identifier:
                        selectedVoiceIdentifier
                )
        }

        speechSynthesizer.speak(
            utterance
        )
    }

    // moves to the next part
    private func playNextPart() {

        guard isReading else {
            return
        }

        currentSpeechPart += 1

        if currentSpeechPart <
            speechParts.count {

            playCurrentPart()

        } else {

            isReading = false
            currentSpeechPart = 0
        }
    }

    // pauses the current speech
    private func pauseText() {

        if speechSynthesizer.isSpeaking &&
            !speechSynthesizer.isPaused {

            speechSynthesizer.pauseSpeaking(
                at: .word
            )
        }
    }

    // stops the current speech
    private func stopText() {

        isReading = false
        currentSpeechPart = 0
        speechParts = []

        speechSynthesizer.stopSpeaking(
            at: .immediate
        )
    }

    // deletes the current text
    private func deleteText() {

        guard let userID = auth.userID else {
            return
        }

        Task {
            await store.deleteText(
                userID: userID,
                textID: text.id
            )

            if store.errorMessage == nil {
                dismiss()
            }
        }
    }
}

// preview for the texts library
struct TextsView_Previews: PreviewProvider {
    static var previews: some View {
        TextsView()
            .environmentObject(AppState())
            .environmentObject(AuthManager())
            .preferredColorScheme(.dark)
    }
}
