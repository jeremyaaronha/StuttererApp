import SwiftUI

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage = "en"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Language", selection: $appLanguage) {
                        Text("English").tag("en")
                        Text("Español").tag("es")
                    }
                } header: {
                    Text("Language")
                } footer: {
                    Text("Choose the language you want to use in the app.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
