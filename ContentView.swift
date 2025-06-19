import SwiftUI

struct ContentView: View {
    @StateObject private var model = TimerModel()
    @State private var showingPrompt = false
    @State private var blink = false

    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.2)
                    .foregroundColor(.blue)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: progress)

                VStack(spacing: 8) {
                    Text(model.intervals[model.currentIndex].title)
                        .font(.title2)
                    Text(timeString)
                        .font(.largeTitle.monospacedDigit())
                        .onTapGesture {
                            model.toggleDirection()
                        }
                }
            }
            .frame(width: 200, height: 200)

            Button(model.isRunning ? "Zastaviť" : "Štart") {
                if model.isRunning {
                    model.stop()
                } else {
                    model.start()
                }
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .opacity(blink ? 0.3 : 1.0)
            .animation(blink ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: blink)
        }
        .padding()
        .onChange(of: model.isRunning) { _, running in
            blink = !running
        }
        .onReceive(NotificationCenter.default.publisher(for: .promptNewCycle)) { _ in
            showingPrompt = true
        }
        .alert(isPresented: $showingPrompt) {
            Alert(title: Text("Začať ďalší pracovný interval?"),
                  primaryButton: .default(Text("Áno")) { model.resume() },
                  secondaryButton: .cancel(Text("Nie")) { model.stop() })
        }
    }

    private var progress: CGFloat {
        let total = CGFloat(model.intervals[model.currentIndex].duration * 60)
        let elapsed = model.isCountDown ? (total - CGFloat(model.seconds)) : CGFloat(model.seconds)
        return elapsed / total
    }

    private var timeString: String {
        let minutes = model.seconds / 60
        let seconds = model.seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
