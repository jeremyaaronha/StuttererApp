import SwiftUI

// branded splash shown briefly on launch then fades into the app

struct SplashView: View {
    // becomes true to trigger the fade in of the logo (that still needs to be put in)
    @State private var appeared = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 16) {
                
                Text("StuttererApp")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(appeared ? 1.0 : 0.9)
            .opacity(appeared ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.5), value: appeared)
        }
        .onAppear { appeared = true }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
