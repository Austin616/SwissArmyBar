import Foundation

final class ClipboardSettingsStore: ObservableObject {
    private let defaults: UserDefaults
    private let storageKey = "clipboardPreferences.v1"
    private var isLoaded = false

    @Published var historyLimit: Int {
        didSet {
            let clamped = min(max(historyLimit, 3), 50)
            if historyLimit != clamped {
                historyLimit = clamped
                return
            }
            save()
        }
    }

    @Published var blockedBundleIds: Set<String> {
        didSet {
            save()
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: storageKey),
           let prefs = try? JSONDecoder().decode(ClipboardPreferences.self, from: data) {
            historyLimit = min(max(prefs.historyLimit, 3), 50)
            blockedBundleIds = Set(prefs.blockedBundleIds)
        } else {
            historyLimit = 8
            blockedBundleIds = []
        }

        isLoaded = true
    }

    private func save() {
        guard isLoaded else { return }
        let prefs = ClipboardPreferences(
            historyLimit: historyLimit,
            blockedBundleIds: Array(blockedBundleIds)
        )
        if let data = try? JSONEncoder().encode(prefs) {
            defaults.set(data, forKey: storageKey)
        }
    }
}

private struct ClipboardPreferences: Codable {
    let historyLimit: Int
    let blockedBundleIds: [String]
}
