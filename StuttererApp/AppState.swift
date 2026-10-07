import Foundation
import Combine

// this is navigation only, add auth later

@MainActor
final class AppState: ObservableObject {

    // dev bypass while building navigation
    // when true the app skips the welcome login screen and opens on the main tabs
    // set this to false to demo the welcome and login flow
    static let devBypassLogin = true

    // which main tab is currently selected
    @Published var selectedTab: MainTab = .practice

    // whether the slide in side menu is open
    @Published var isMenuOpen: Bool = false

    // whether the user has passed the welcome login screen
    @Published var isSignedIn: Bool

    // simple name shown on the profile screen the auth team can set this later
    @Published var userName: String = "Guest"

    // placeholder device status used by the status indicator and headphone requirement message
    // real values will be wired to audio manager later
    @Published var isMicConnected: Bool = true
    @Published var areHeadphonesConnected: Bool = false

    init() {
        isSignedIn = Self.devBypassLogin
    }

    // called by the welcome screen buttons real login comes later from the auth team
    func signIn() {
        isSignedIn = true
    }

    // called by the sign out buttons after AuthManager signs out,
    // so the next person to sign in starts on the practice tab with the menu closed
    func signOut() {
        isSignedIn = false
        selectedTab = .practice
        isMenuOpen = false
    }
}

// the four main sections reachable from the tab bar
enum MainTab: Hashable {
    case practice
    case controls
    case texts
    case challenges
    case profile
}
