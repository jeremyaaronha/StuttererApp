//
//  StuttererAppApp.swift
//  StuttererApp
//
//

import SwiftUI
import FirebaseCore

@main
struct StuttererAppApp: App {

    // login state shared with every screen
    @StateObject private var auth: AuthManager

    init() {
        // starts firebase once GoogleService-Info.plist is in the project
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }

        // created after firebase starts so it can check the saved login
        _auth = StateObject(wrappedValue: AuthManager())
    }

    var body: some Scene {
        WindowGroup {
            // shows the app when logged in, otherwise the login screen
            Group {
                if auth.isSignedIn {
                    ContentView()
                } else {
                    AuthView()
                }
            }
            .environmentObject(auth)
        }
    }
}
