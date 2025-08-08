import Foundation

/// Provides repeating timer functionality with callback support.
final class RepeatingTimerService {
    private var timer: Timer?
    private let interval: TimeInterval
    private let queue: DispatchQueue
    private var callback: (() -> Void)?
    
    init(interval: TimeInterval = 60, queue: DispatchQueue = .main) {
        self.interval = interval
        self.queue = queue
    }
    
    func schedule(startAtNextExactMinute: Bool = true, callback: @escaping () -> Void) {
        self.callback = callback
        cancel()

        let now = Date()
        let calendar = Calendar.current
        if startAtNextExactMinute,
           let nextMinute = calendar.nextDate(after: now, matching: DateComponents(second: 0), matchingPolicy: .strict) {
            let delay = nextMinute.timeIntervalSince(now)

            queue.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.callback?()
                self?.startRepeating()
            }
        } else {
            startRepeating()
        }
    }
    
    func cancel() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startRepeating() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.callback?()
        }
    }
    
    deinit {
        cancel()
    }
}
