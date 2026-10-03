import SwiftUI

// create or edit a practice text
struct TextEditorView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var auth: AuthManager

    @ObservedObject var store: PracticeTextStore

    let text: PracticeText?

    @State private var title: String
    @State private var content: String
    @State private var isSaving = false

    init(
        store: PracticeTextStore,
        text: PracticeText? = nil
    ) {
        self.store = store
        self.text = text

        _title = State(initialValue: text?.title ?? "")
        _content = State(initialValue: text?.content ?? "")
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    ScreenHeader(
                        title: text == nil ? "New Text" : "Edit Text",
                        subtitle: "PRACTICE TEXT"
                    )

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {

                            Text("Title")
                                .font(.headline)

                            TextField("Practice text title", text: $title)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {

                            Text("Practice Text")
                                .font(.headline)

                            TextEditor(text: $content)
                                .frame(minHeight: 250)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.black.opacity(0.15))
                                )
                        }
                    }

                    Button {
                        saveText()
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView()
                            }

                            Text(isSaving ? "Saving..." : "Save Text")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        title.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ||
                        content.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ||
                        isSaving
                    )
                }
                .padding(24)
            }
        }
    }

    // saves a new text or updates the current one
    private func saveText() {

        guard let userID = auth.userID else {
            store.errorMessage = "User not signed in."
            return
        }

        let cleanTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanContent = content.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        isSaving = true

        Task {
            if var existingText = text {

                existingText.title = cleanTitle
                existingText.content = cleanContent
                existingText.updatedAt = Date()

                await store.updateText(
                    userID: userID,
                    text: existingText
                )

            } else {

                await store.createText(
                    userID: userID,
                    title: cleanTitle,
                    content: cleanContent
                )
            }

            isSaving = false

            if store.errorMessage == nil {
                dismiss()
            }
        }
    }
}
