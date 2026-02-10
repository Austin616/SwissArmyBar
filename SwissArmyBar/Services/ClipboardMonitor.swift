import AppKit
import Combine
import Foundation

final class ClipboardMonitor: ObservableObject {
    @Published private(set) var items: [ClipboardItem] = []

    private let settings: ClipboardSettingsStore
    private var pasteboardChangeCount: Int
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init(settings: ClipboardSettingsStore) {
        self.settings = settings
        self.pasteboardChangeCount = NSPasteboard.general.changeCount
        bindSettings()
        start()
    }

    deinit {
        stop()
    }

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            self?.pollPasteboard()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func clear() {
        items.removeAll()
    }

    func remove(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
    }

    private func bindSettings() {
        settings.$historyLimit
            .sink { [weak self] _ in
                self?.trimToLimit()
            }
            .store(in: &cancellables)
    }

    private func pollPasteboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != pasteboardChangeCount else { return }
        pasteboardChangeCount = pasteboard.changeCount

        let frontmost = NSWorkspace.shared.frontmostApplication
        if let bundleId = frontmost?.bundleIdentifier,
           settings.blockedBundleIds.contains(bundleId) {
            return
        }

        guard let text = pasteboard.string(forType: .string),
              !text.isEmpty else { return }

        if let first = items.first, first.text == text {
            return
        }

        let source = frontmost?.localizedName ?? "Unknown"
        let item = ClipboardItem(text: text, source: source, timestamp: "just now")
        items.insert(item, at: 0)
        trimToLimit()
    }

    private func trimToLimit() {
        let limit = max(3, settings.historyLimit)
        if items.count > limit {
            items = Array(items.prefix(limit))
        }
    }
}
