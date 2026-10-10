import SwiftUI

// audio controls tab
// controls the voice effects and audio settings

struct ControlsView: View {

    @ObservedObject var audioManager: AudioManager

    // shows "Saved" on the button for a moment after a tap
    @State private var showSaved = false

    var body: some View {

        ZStack {

            Theme.background
                .ignoresSafeArea()

            ScrollView {

                VStack(spacing: 20) {

                    ScreenHeader(
                        title: "Controls",
                        subtitle: "VOCAL TUNING"
                    )

                    GlassCard {

                        VStack(alignment: .leading, spacing: 20) {


                            sliderRow(
                                title: "Voice 1 Delay",
                                value: String(
                                    format: "%.2f s",
                                    audioManager.delayTime1
                                )
                            ) {

                                Slider(
                                    value: $audioManager.delayTime1,
                                    in: AudioManager.delayRange,
                                    onEditingChanged: { isDragging in

                                        // one write when the drag ends,
                                        // not one per frame
                                        if !isDragging {
                                            audioManager.saveSettings()
                                        }
                                    }
                                )
                                .tint(.cyan)
                            }


                            sliderRow(
                                title: "Voice 2 Delay",
                                value: String(
                                    format: "%.2f s",
                                    audioManager.delayTime2
                                )
                            ) {

                                Slider(
                                    value: $audioManager.delayTime2,
                                    in: AudioManager.delayRange,
                                    onEditingChanged: { isDragging in

                                        // one write when the drag ends,
                                        // not one per frame
                                        if !isDragging {
                                            audioManager.saveSettings()
                                        }
                                    }
                                )
                                .tint(.cyan)
                            }


                            sliderRow(
                                title: "Voice Effect",
                                value: "\(Int(audioManager.voiceEffect))"
                            ) {

                                Slider(
                                    value: $audioManager.voiceEffect,
                                    in: AudioManager.voiceEffectRange,
                                    onEditingChanged: { isDragging in

                                        // one write when the drag ends,
                                        // not one per frame
                                        if !isDragging {
                                            audioManager.saveSettings()
                                        }
                                    }
                                )
                                .tint(.orange)
                            }


                            sliderRow(
                                title: "Voice 2 Volume",
                                value: "\(Int(audioManager.voice2Volume * 100))%"
                            ) {

                                Slider(
                                    value: $audioManager.voice2Volume,
                                    in: AudioManager.voice2VolumeRange,
                                    onEditingChanged: { isDragging in

                                        // one write when the drag ends,
                                        // not one per frame
                                        if !isDragging {
                                            audioManager.saveSettings()
                                        }
                                    }
                                )
                                .tint(.purple)
                            }


                            Button {

                                audioManager.saveSettings()
                                showSaved = true

                                Task {
                                    try? await Task.sleep(for: .seconds(1.5))
                                    showSaved = false
                                }

                            } label: {

                                Text(
                                    LocalizedStringKey(
                                        showSaved ? "Saved" : "Save Settings"
                                    )
                                )
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.cyan.opacity(0.7))
                                .cornerRadius(20)
                            }


                            Button {

                                audioManager.resetSettings()

                            } label: {

                                Text("Reset")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        Color.gray.opacity(0.5)
                                    )
                                    .cornerRadius(20)
                            }


                            Button {

                                audioManager.toggleAudio()

                            } label: {

                                Text(
                                    LocalizedStringKey(
                                        audioManager.isRunning ? "Stop" : "Start"
                                    )
                                )
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    audioManager.isRunning
                                    ? Color.red
                                    : Color.green
                                )
                                .cornerRadius(20)
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

                Text(LocalizedStringKey(title))
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


struct ControlsView_Previews: PreviewProvider {

    static var previews: some View {

        ControlsView(
            audioManager: AudioManager()
        )
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
    }
}
