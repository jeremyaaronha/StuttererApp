import SwiftUI

// shows device status the headphone requirement message and a primary call to action to start a session
// the practice actions route the user to the audio controls tab
struct PracticeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    ScreenHeader(title: "StuttererApp", subtitle: "PRACTICE HOME")

                    // clear status indicator mic and headphones
                    StatusIndicator(
                        isMicConnected: appState.isMicConnected,
                        areHeadphonesConnected: appState.areHeadphonesConnected
                    )
                    .appearCard()

                    // headphone requirement message shown when no headphones detected
                    if !appState.areHeadphonesConnected {
                        HeadphoneRequirementBanner()
                            .appearCard(delay: 0.05)
                    }

                    GlassCard {
                        VStack(spacing: 14) {
                            Text("READY TO ASSIST")
                                .font(.caption.weight(.bold))
                                .foregroundColor(Theme.accent)
                            Text("Start Your Session")
                                .font(.title.weight(.bold))
                            Text("Put on both headphones. Speak naturally. Your voice will be accompanied by two delayed feedback signals.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button {
                                openControls()
                            } label: {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 64))
                                    .foregroundColor(Theme.accent)
                                    .padding(.top, 4)
                            }
                            .buttonStyle(PressableButtonStyle())
                            .accessibilityLabel("Play")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .appearCard(delay: 0.1)

                    Button {
                        openControls()
                    } label: {
                        Text("Start Session")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.start)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: Theme.start.opacity(0.4), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .appearCard(delay: 0.15)

                    GlassCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("ACTIVE DELAY SETTINGS")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)
                                Text("Default Pitch & Shift")
                                    .font(.subheadline.weight(.semibold))
                            }
                            Spacer()
                            Text("75ms / 150ms")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(Theme.accent)
                        }
                    }
                    .appearCard(delay: 0.2)

                }
                .padding(24)
            }
        }
    }

    private func openControls() {
        appState.selectedTab = .controls
    }
}

// preview open this file to see the practice home screen
struct PracticeView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}
