import Foundation
import Combine
import FirebaseFirestore

// manages saved practice texts
@MainActor
final class PracticeTextStore: ObservableObject {

    @Published var texts: [PracticeText] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    // starts listening for the current user's texts
    func startListening(userID: String) {

        listener?.remove()

        listener = db
            .collection("users")
            .document(userID)
            .collection("practiceTexts")
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in

                if let error {
                    self?.errorMessage = error.localizedDescription
                    return
                }

                guard let documents = snapshot?.documents else {
                    return
                }

                self?.texts = documents.compactMap { document in

                    let data = document.data()

                    guard
                        let title = data["title"] as? String,
                        let content = data["content"] as? String
                    else {
                        return nil
                    }

                    let createdAt =
                        (data["createdAt"] as? Timestamp)?.dateValue()
                        ?? Date()

                    let updatedAt =
                        (data["updatedAt"] as? Timestamp)?.dateValue()
                        ?? Date()

                    return PracticeText(
                        id: document.documentID,
                        title: title,
                        content: content,
                        createdAt: createdAt,
                        updatedAt: updatedAt
                    )
                }
            }
    }

    // creates a new text
    func createText(
        userID: String,
        title: String,
        content: String
    ) async {

        let document = db
            .collection("users")
            .document(userID)
            .collection("practiceTexts")
            .document()

        do {
            try await document.setData([
                "title": title,
                "content": content,
                "createdAt": Timestamp(date: Date()),
                "updatedAt": Timestamp(date: Date())
            ])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // updates an existing text
    func updateText(
        userID: String,
        text: PracticeText
    ) async {

        do {
            try await db
                .collection("users")
                .document(userID)
                .collection("practiceTexts")
                .document(text.id)
                .updateData([
                    "title": text.title,
                    "content": text.content,
                    "updatedAt": Timestamp(date: Date())
                ])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // deletes a saved text
    func deleteText(
        userID: String,
        textID: String
    ) async {

        do {
            try await db
                .collection("users")
                .document(userID)
                .collection("practiceTexts")
                .document(textID)
                .delete()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // stops listening for changes
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
