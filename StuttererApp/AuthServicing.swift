//
//  AuthServicing.swift
//  StuttererApp

import Foundation

// minimal info AuthManager actually needs about a signed-in user,
// independent of Firebase's own User type
struct AuthUser {
    let uid: String
    let email: String?
}

// everything AuthManager needs from Firebase, abstracted so tests
// can swap in a fake implementation instead of hitting real Firebase
protocol AuthServicing {
    var currentUser: AuthUser? { get }

    func createUser(email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() throws
    func sendPasswordReset(email: String) async throws

    func listen(onChange: @escaping (AuthUser?) -> Void)
    func stopListening()
}
