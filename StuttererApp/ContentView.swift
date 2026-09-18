import SwiftUI

struct ContentView: View {
    
    // controls the audio
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
        
        // main background
        ZStack {
            
            // app background
            LinearGradient(
                colors: [Color.black, Color.blue.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // app content
            VStack(spacing: 35) {
                
                // title
                Text("Stutterer App")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    
                    // shows first delay
                    Text("Voice 1 Delay: \(audioManager.delayTime1, specifier: "%.2f") s")
                        .foregroundColor(.white)
                    
                    // changes first delay
                    Slider(
                        value: $audioManager.delayTime1,
                        in: 0...0.5
                    )
                    .accentColor(.cyan)
                    .padding(.horizontal)
                    
                    // shows second delay
                    Text("Voice 2 Delay: \(audioManager.delayTime2, specifier: "%.2f") s")
                        .foregroundColor(.white)
                    
                    // changes second delay
                    Slider(
                        value: $audioManager.delayTime2,
                        in: 0...0.5
                    )
                    .accentColor(.cyan)
                    .padding(.horizontal)
                    
                    // shows voice effect
                    Text("Voice 2 Effect: \(Int(audioManager.voiceEffect))")
                        .foregroundColor(.white)
                    
                    // changes voice effect
                    Slider(
                        value: $audioManager.voiceEffect,
                        in: -20...20
                    )
                    .accentColor(.orange)
                    .padding(.horizontal)
                    
                    // shows second voice volume
                    Text("Voice 2 Volume: \(Int(audioManager.voice2Volume * 100))%")
                        .foregroundColor(.white)
                    
                    // changes second voice volume
                    Slider(
                        value: $audioManager.voice2Volume,
                        in: 0...1
                    )
                    .accentColor(.purple)
                    .padding(.horizontal)
                    
                    // resets values
                    Button(action: {
                        audioManager.resetSettings()
                    }) {
                        Text("Reset")
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(20)
                    }
                    
                    // starts or stops audio
                    Button(action: {
                        audioManager.toggleAudio()
                    }) {
                        
                        // changes button text
                        Text(audioManager.isRunning ? "Stop" : "Start")
                            .font(.system(size: 22, weight: .bold))
                            .frame(width: 200, height: 60)
                            .background(
                                audioManager.isRunning
                                ? Color.red
                                : Color.green
                            )
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .shadow(radius: 10)
                    }
                }
            }
        }
    }
}
