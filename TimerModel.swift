import SwiftUI
import UserNotifications
import AudioToolbox
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
        seconds = 0
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
