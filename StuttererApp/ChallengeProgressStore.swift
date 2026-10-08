import Foundation
import Combine

// tracks which speech sound challenges the user has completed
// persists locally per user with UserDefaults, matching the audio settings approach
@MainActor
final class ChallengeProgressStore: ObservableObject {

    // ids of every challenge the user has mastered
    @Published private(set) var completedIDs: Set<String> = []

    private var userID: String = "guest"

    private var storageKey: String {
        "completedChallenges_\(userID)"
    }

    // loads saved progress for the given user
    func load(for userID: String) {
        self.userID = userID

        let saved = UserDefaults.standard
            .stringArray(forKey: storageKey) ?? []

        completedIDs = Set(saved)
    }

    // whether a specific challenge has been completed
    func isCompleted(_ challengeID: String) -> Bool {
        completedIDs.contains(challengeID)
    }

    // marks a challenge as completed and saves
    func markCompleted(_ challengeID: String) {
        guard !completedIDs.contains(challengeID) else { return }
        completedIDs.insert(challengeID)
        save()
    }

    // number of completed challenges for a sound
    func completedCount(for sound: SpeechSound) -> Int {
        sound.challenges.filter { completedIDs.contains($0.id) }.count
    }

    // saves the current progress
    private func save() {
        UserDefaults.standard.set(
            Array(completedIDs),
            forKey: storageKey
        )
    }
}
