import SwiftUI

// settings screen, presented as a sheet from the Profile menu
// holds the appearance toggle and a placeholder language row
struct SettingsView: View {

    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = true

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

    // light / dark appearance control
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            sectionLabel("APPEARANCE")

            GlassCard {
                Picker("Appearance", selection: $isDarkMode.animation(.easeInOut(duration: 0.25))) {
                    Text("Light").tag(false)
                    Text("Dark").tag(true)
                }
                .pickerStyle(.segmented)
                .tint(Theme.accent)
            }

            caption("Choose a light or dark look for the app.")
        }
    }

    // placeholder language row, kept non-interactive so it doesn't collide
    // with the localization work in progress
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            sectionLabel("LANGUAGE")

            GlassCard {
                HStack {
                    Text("App Language")
                        .font(.body)

                    Spacer()

                    Text("English")
                        .font(.body)
                        .foregroundColor(.secondary)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }
            }
            .opacity(0.6)
            .allowsHitTesting(false)

            caption("Español support is on the way.")
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(.secondary)
            .padding(.leading, 4)
    }

    private func caption(_ text: String) -> some View {
        Text(text)
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
