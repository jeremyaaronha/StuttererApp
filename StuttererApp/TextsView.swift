import SwiftUI

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
                                .buttonStyle(.plain)
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

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        Text(currentText.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        GlassCard {
                            Text(currentText.content)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                        }

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
                    .padding(24)
                }
            }
            .navigationTitle("Practice Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
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
            Button("Cancel", role: .cancel) { }

            Button("Delete", role: .destructive) {
                deleteText()
            }
        } message: {
            Text("Are you sure you want to delete this text?")
        }
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
