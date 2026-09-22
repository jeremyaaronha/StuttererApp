//
//  StuttererAppApp.swift
//  StuttererApp
//
//

import SwiftUI

@main
struct StuttererAppApp: App {

    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
