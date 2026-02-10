import Foundation
import Combine

final class TimerStore: ObservableObject {
    @Published var durationMinutes: Int {
        didSet {
            let clamped = min(max(durationMinutes, 5), 90)
            if durationMinutes != clamped {
                durationMinutes = clamped
                return
            }
            if !isRunning {
                remainingSeconds = durationMinutes * 60
            } else {
                remainingSeconds = min(remainingSeconds, durationMinutes * 60)
            }
            save()
        }
    }
    @Published var remainingSeconds: Int
    @Published var isRunning: Bool {
        didSet { save() }
    }
    @Published var autoDNDEnabled: Bool {
        didSet { save() }
    }
    @Published var playEndSound: Bool {
        didSet { save() }
    }

    private let defaults: UserDefaults
    private let storageKey = "timerPreferences.v1"
    private var isLoaded = false
    private var timer: Timer?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let resolvedDuration: Int
        let resolvedRemaining: Int
        let resolvedIsRunning: Bool
        let resolvedAutoDND: Bool
        let resolvedPlayEnd: Bool

        if let data = defaults.data(forKey: storageKey),
           let prefs = try? JSONDecoder().decode(TimerPreferences.self, from: data) {
            resolvedDuration = min(max(prefs.durationMinutes, 5), 90)
            resolvedRemaining = min(max(prefs.remainingSeconds, 0), resolvedDuration * 60)
            resolvedIsRunning = prefs.isRunning
            resolvedAutoDND = prefs.autoDNDEnabled
            resolvedPlayEnd = prefs.playEndSound
        } else {
            resolvedDuration = 25
            resolvedRemaining = 25 * 60
            resolvedIsRunning = false
            resolvedAutoDND = true
            resolvedPlayEnd = true
        }

        durationMinutes = resolvedDuration
        remainingSeconds = resolvedRemaining
        isRunning = resolvedIsRunning
        autoDNDEnabled = resolvedAutoDND
        playEndSound = resolvedPlayEnd

        isLoaded = true
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    func start() {
        if remainingSeconds == 0 {
            remainingSeconds = durationMinutes * 60
        }
        isRunning = true
    }

    func pause() {
        isRunning = false
    }

    func reset() {
        isRunning = false
        remainingSeconds = durationMinutes * 60
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard isRunning, remainingSeconds > 0 else { return }
        remainingSeconds -= 1
        if remainingSeconds == 0 {
            isRunning = false
        }
    }

    private func save() {
        guard isLoaded else { return }
        let prefs = TimerPreferences(
            durationMinutes: durationMinutes,
            remainingSeconds: remainingSeconds,
            isRunning: isRunning,
            autoDNDEnabled: autoDNDEnabled,
            playEndSound: playEndSound
        )
        if let data = try? JSONEncoder().encode(prefs) {
            defaults.set(data, forKey: storageKey)
        }
    }
}

private struct TimerPreferences: Codable {
    let durationMinutes: Int
    let remainingSeconds: Int
    let isRunning: Bool
    let autoDNDEnabled: Bool
    let playEndSound: Bool
}
