import SwiftUI

struct ContentView: View {
    
    // controls the audio manager
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
        
        // creates main background layout
        ZStack {
            
            // creates app background
            LinearGradient(
                colors: [Color.black, Color.blue.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // organizes app elements vertically
            VStack(spacing: 50) {
                
                // title
                Text("Mic Monitor")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    
                    // shows current delay time
                    Text("Delay: \(audioManager.delayTime, specifier: "%.2f") s")
                        .foregroundColor(.white)
                    
                    // changes voice delay
                    Slider(value: $audioManager.delayTime,
                           in: 0...0.5)
                    .accentColor(.cyan)
                    .padding(.horizontal)
                    
                    // shows tone option
                    Text("Tone")
                        .foregroundColor(.white)
                    
                    // changes voice tone
                    Slider(value: $audioManager.toneAmount,
                           in: -20...20)
                    .accentColor(.orange)
                    .padding(.horizontal)
                    
                    // button to start or stop
                    Button(action: {
                        audioManager.toggleAudio()
                    }) {
                        // changes button text depending on status
                        Text(audioManager.isRunning ? "Stop" : "Start")
                            .font(.system(size: 22, weight: .bold))
                            .frame(width: 200, height: 60)
                            .background(audioManager.isRunning ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .shadow(radius: 10)
                    }
                }
            }
        }
    }
}
