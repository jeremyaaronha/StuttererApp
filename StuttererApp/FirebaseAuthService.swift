//
//  FirebaseAuthService.swift
//  StuttererApp
//
import FirebaseAuth

final class FirebaseAuthService: AuthServicing {

    private var listenerHandle: AuthStateDidChangeListenerHandle?

    var currentUser: AuthUser? {
        guard let user = Auth.auth().currentUser else { return nil }
        return AuthUser(uid: user.uid, email: user.email)
    }

    func createUser(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func listen(onChange: @escaping (AuthUser?) -> Void) {
        listenerHandle = Auth.auth().addStateDidChangeListener { _, user in
            onChange(user.map { AuthUser(uid: $0.uid, email: $0.email) })
        }
    }

    func stopListening() {
        if let listenerHandle {
            Auth.auth().removeStateDidChangeListener(listenerHandle)
        }
    }
}
