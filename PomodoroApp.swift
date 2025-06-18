import SwiftUI
import UserNotifications
import AudioToolbox

@main
struct PomodoroApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                print("Notifications allowed")
            }
        }
        return true
    }
}

class TimerModel: ObservableObject {
    struct Interval {
        let title: String
        let duration: Int
    }

    let intervals: [Interval] = [
        .init(title: "Práca", duration: 25),
        .init(title: "Pauza", duration: 5),
        .init(title: "Práca", duration: 25),
        .init(title: "Pauza", duration: 5),
        .init(title: "Práca", duration: 25),
        .init(title: "Pauza", duration: 5),
        .init(title: "Práca", duration: 25),
        .init(title: "Dlhšia pauza", duration: 30)
    ]
    let totalWorkdaySeconds = 8 * 60 * 60

    @Published var currentIndex = 0
    /// Number of seconds either counting down or up for the current interval
    @Published var seconds: Int
    @Published var totalElapsed = 0
    var timer: Timer?
    @Published var isRunning = false
    /// `true` means the timer counts down from the interval duration.
    /// `false` means it counts up from zero.
    @Published var isCountDown = true

    init() {
        let duration = intervals[0].duration * 60
        seconds = isCountDown ? duration : 0
    }

    /// Sets the `seconds` value for the current interval based on the
    /// `isCountDown` flag.
    private func setupSecondsForCurrentInterval() {
        let duration = intervals[currentIndex].duration * 60
        seconds = isCountDown ? duration : 0
    }

    /// Toggles between counting down from the interval duration and counting up
    /// from zero.
    func toggleDirection() {
        let duration = intervals[currentIndex].duration * 60
        seconds = duration - seconds
        isCountDown.toggle()
    }

    func start() {
        timer?.invalidate()
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.tick()
        }
    }

    private func tick() {
        guard totalElapsed < totalWorkdaySeconds else {
            stop()
            return
        }

        let duration = intervals[currentIndex].duration * 60
        if isCountDown {
            if seconds > 0 {
                seconds -= 1
                totalElapsed += 1
            } else {
                handleIntervalEnd(duration: duration)
            }
        } else {
            if seconds < duration {
                seconds += 1
                totalElapsed += 1
            } else {
                handleIntervalEnd(duration: duration)
            }
        }
    }

    private func handleIntervalEnd(duration: Int) {
        notifyIntervalEnd()
        currentIndex = (currentIndex + 1) % intervals.count
        setupSecondsForCurrentInterval()
        if intervals[currentIndex].title.contains("Pauza") == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .promptNewCycle, object: nil)
            }
        }
    }

    private func notifyIntervalEnd() {
        AudioServicesPlaySystemSound(SystemSoundID(1322))
        let content = UNMutableNotificationContent()
        content.title = "Koniec \(intervals[currentIndex].title)"
        content.body = "Začína \(intervals[(currentIndex + 1) % intervals.count].title)"
        content.sound = UNNotificationSound.default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func resume() { start() }
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
}

extension Notification.Name {
    static let promptNewCycle = Notification.Name("promptNewCycle")
}

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
        .onChange(of: model.isRunning) { running in
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
