//
//  StuttererAppApp.swift
//  StuttererApp
//
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct StuttererAppApp: App {

    @StateObject private var appState = AppState()

    @StateObject private var auth: AuthManager

    init() {

        if Bundle.main.path(
            forResource: "GoogleService-Info",
            ofType: "plist"
        ) != nil {

            FirebaseApp.configure()
        }

        _auth = StateObject(
            wrappedValue: AuthManager()
        )
    }

    var body: some Scene {

        WindowGroup {

            Group {

                if auth.isSignedIn {
                    ContentView()
                } else {
                    AuthView()
                }
            }
            .environmentObject(appState)
            .environmentObject(auth)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
