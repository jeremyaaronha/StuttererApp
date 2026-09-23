import SwiftUI

// shows device status the headphone requirement message and a primary call to action to start a session
// the start button is visual but has no logic connected to it
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

                    // headphone requirement message shown when no headphones detected
                    if !appState.areHeadphonesConnected {
                        HeadphoneRequirementBanner()
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
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(Theme.accent)
                                .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // start session is handled by the audio feature owner
                    // green primary action echoing the teammate original
                    Button {
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
                }
                .padding(24)
            }
        }
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
