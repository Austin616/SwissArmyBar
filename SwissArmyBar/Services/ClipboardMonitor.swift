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

        if let imageData = readImageData(from: pasteboard) {
            if let first = items.first, first.content == .image(imageData) {
                return
            }
            let source = frontmost?.localizedName ?? "Unknown"
            let item = ClipboardItem(content: .image(imageData), source: source, timestamp: "just now")
            items.insert(item, at: 0)
            trimToLimit()
            return
        }

        guard let text = pasteboard.string(forType: .string),
              !text.isEmpty else { return }

        if let first = items.first, first.content == .text(text) {
            return
        }

        let source = frontmost?.localizedName ?? "Unknown"
        let item = ClipboardItem(content: .text(text), source: source, timestamp: "just now")
        items.insert(item, at: 0)
        trimToLimit()
    }

    private func readImageData(from pasteboard: NSPasteboard) -> Data? {
        if let pngData = pasteboard.data(forType: .png) {
            return pngData
        }
        if let tiffData = pasteboard.data(forType: .tiff),
           let image = NSImage(data: tiffData),
           let pngData = image.pngData() {
            return pngData
        }
        if let image = NSImage(pasteboard: pasteboard),
           let pngData = image.pngData() {
            return pngData
        }
        return nil
    }

    private func trimToLimit() {
        let limit = max(3, settings.historyLimit)
        if items.count > limit {
            items = Array(items.prefix(limit))
        }
    }
}
