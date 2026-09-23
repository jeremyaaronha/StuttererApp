import SwiftUI

// audio controls tab
// provides simple controls bound to the existing audio manager so the tab is functional as a navigation target
// the full tuning ui multiple voices presets is owned by the audio feature team and can expand this later
struct ControlsView: View {
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    ScreenHeader(title: "Controls", subtitle: "VOCAL TUNING")

                    GlassCard {
                        VStack(alignment: .leading, spacing: 20) {

                            sliderRow(
                                title: "Delay",
                                value: String(format: "%.2f s", audioManager.delayTime)
                            ) {
                                Slider(value: $audioManager.delayTime, in: 0...0.5)
                                    .tint(.cyan)
                            }

                            sliderRow(
                                title: "Tone",
                                value: String(format: "%.0f", audioManager.toneAmount)
                            ) {
                                Slider(value: $audioManager.toneAmount, in: -20...20)
                                    .tint(.orange)
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
    }

    // reusable labeled slider row
    private func sliderRow<Control: View>(
        title: String,
        value: String,
        @ViewBuilder control: () -> Control
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(value)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(Theme.accent)
            }
            control()
        }
    }
}

// preview open this file to see the audio controls screen
struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(audioManager: AudioManager())
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}
