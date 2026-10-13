//
//  ProfileStore.swift
//  StuttererApp
//

import Foundation
import Combine
import UIKit
import FirebaseFirestore

// loads and saves the signed in user's profile (name and photo)
@MainActor
final class ProfileStore: ObservableObject {

    @Published private(set) var firstName = ""
    @Published private(set) var lastName = ""

    // small jpeg of the profile photo, nil when the user hasn't picked one
    @Published private(set) var photoData: Data?

    @Published private(set) var isSaving = false
    @Published var errorMessage: String?

    // which user the values above belong to
    private(set) var userID: String?

    private let db = Firestore.firestore()

    // the photo is stored inside the firestore document, so it has to stay
    // well under firestore's 1 MB document limit
    nonisolated static let maxPhotoSide: CGFloat = 300

    // first and last name together, or nil if both are empty
    var fullName: String? {
        Self.fullName(first: firstName, last: lastName)
    }

    // users/{uid}/profile/info, next to the user's practiceTexts
    private func document(for userID: String) -> DocumentReference {
        db.collection("users")
            .document(userID)
            .collection("profile")
            .document("info")
    }

    // reads the profile for this user, clearing the last user's values first
    // so one person never sees another person's name or photo
    func load(userID: String) async {
        guard userID != self.userID else { return }

        self.userID = userID
        firstName = ""
        lastName = ""
        photoData = nil

        do {
            let snapshot = try await document(for: userID).getDocument()

            // a different user signed in while this was loading
            guard userID == self.userID, let data = snapshot.data() else {
                return
            }

            firstName = data["firstName"] as? String ?? ""
            lastName = data["lastName"] as? String ?? ""
            photoData = data["photo"] as? Data
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // saves the profile and returns true when it worked
    func save(firstName: String, lastName: String, photoData: Data?) async -> Bool {
        guard let userID else { return false }

        let first = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let last = lastName.trimmingCharacters(in: .whitespacesAndNewlines)

        isSaving = true
        defer { isSaving = false }

        do {
            try await document(for: userID).setData([
                "firstName": first,
                "lastName": last,
                // NSNull removes the photo if the user took it away
                "photo": photoData ?? NSNull(),
                "updatedAt": Timestamp(date: Date())
            ])

            self.firstName = first
            self.lastName = last
            self.photoData = photoData
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // forgets the profile, used when the user signs out
    func clear() {
        userID = nil
        firstName = ""
        lastName = ""
        photoData = nil
        errorMessage = nil
    }

    // "Ana" + "Lopez" -> "Ana Lopez", blank names are skipped
    nonisolated static func fullName(first: String, last: String) -> String? {
        let parts = [first, last]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    // shrinks a picked photo so its longest side is maxPhotoSide, as a jpeg
    nonisolated static func compressedPhoto(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }

        let longest = max(image.size.width, image.size.height)
        let scale = min(1, maxPhotoSide / longest)
        let size = CGSize(
            width: (image.size.width * scale).rounded(),
            height: (image.size.height * scale).rounded()
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.jpegData(compressionQuality: 0.7)
    }
}
