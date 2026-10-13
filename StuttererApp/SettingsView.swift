import SwiftUI

// settings screen with appearance and language options
struct SettingsView: View {

    @Environment(\.dismiss) private var dismiss

    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("appLanguage") private var appLanguage = "en"

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        appearanceSection

                        languageSection

                        Text("StuttererApp v1.0")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // light and dark appearance control
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            sectionLabel("APPEARANCE")

            GlassCard {
                Picker(
                    "Appearance",
                    selection: $isDarkMode.animation(.easeInOut(duration: 0.25))
                ) {
                    Text("Light").tag(false)
                    Text("Dark").tag(true)
                }
                .pickerStyle(.segmented)
                .tint(Theme.accent)
            }

            caption("Choose a light or dark look for the app.")
        }
    }

    // language selector
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            sectionLabel("LANGUAGE")

            GlassCard {
                Picker("App Language", selection: $appLanguage) {
                    Text("English").tag("en")
                    Text("Español").tag("es")
                }
                .pickerStyle(.segmented)
                .tint(Theme.accent)
            }

            caption("Choose the language you want to use in the app.")
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.caption.weight(.semibold))
            .foregroundColor(.secondary)
            .padding(.leading, 4)
    }

    private func caption(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.leading, 4)
    }
}

// preview for the settings screen
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
