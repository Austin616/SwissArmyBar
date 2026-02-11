import AppKit
import Combine
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    var appEnvironment: AppEnvironment? {
        didSet {
            if hasLaunched {
                configurePopover()
                bindTimerTitle()
            }
        }
    }

    private var statusItem: NSStatusItem?
    private let popover = NSPopover()
    private var cancellables = Set<AnyCancellable>()
    private var mainWindow: NSWindow?
    private var hasLaunched = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        hasLaunched = true
        configureStatusItem()
        NSApp.setActivationPolicy(.accessory)
        if appEnvironment != nil {
            configurePopover()
            bindTimerTitle()
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openMainWindow),
            name: .openMainWindow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWindowVisibilityChange),
            name: NSWindow.willCloseNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWindowVisibilityChange),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )
        DispatchQueue.main.async { [weak self] in
            self?.mainWindow = self?.resolveMainWindow()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "SwissArmyBar")
            button.imagePosition = .imageOnly
            button.title = ""
            button.target = self
            button.action = #selector(handleStatusItemClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        statusItem = item
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self

        if let env = appEnvironment {
            let view = MenuBarPopoverView()
                .environmentObject(env.appSettings)
                .environmentObject(env.clipboardSettings)
                .environmentObject(env.clipboardMonitor)
                .environmentObject(env.sidebarSettings)
                .environmentObject(env.timerStore)
                .environmentObject(env.themeStore)
            popover.contentViewController = NSHostingController(rootView: view)
        }
    }

    private func bindTimerTitle() {
        guard let timerStore = appEnvironment?.timerStore else { return }

        timerStore.$remainingSeconds
            .combineLatest(timerStore.$isRunning)
            .receive(on: RunLoop.main)
            .sink { [weak self] remaining, isRunning in
                guard let button = self?.statusItem?.button else { return }
                if isRunning {
                    button.imagePosition = .imageLeading
                    button.title = Self.formatTime(remaining)
                } else {
                    button.title = ""
                    button.imagePosition = .imageOnly
                }
            }
            .store(in: &cancellables)
    }

    @objc private func handleStatusItemClick() {
        guard let event = NSApp.currentEvent else { return }
        NSRunningApplication.current.activate(options: [.activateIgnoringOtherApps])
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }

    private func togglePopover() {
        guard let button = statusItem?.button else { return }
        let targetScreen = button.window?.screen
        let currentScreen = popover.contentViewController?.view.window?.screen
        if popover.isShown {
            popover.performClose(nil)
            if currentScreen != targetScreen {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    NSRunningApplication.current.activate(options: [.activateIgnoringOtherApps])
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                    }
                }
            }
            return
        }
        NSRunningApplication.current.activate(options: [.activateIgnoringOtherApps])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self else { return }
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func popoverWillShow(_ notification: Notification) {
        guard let window = popover.contentViewController?.view.window else { return }
        window.level = .statusBar
        window.collectionBehavior.insert([.canJoinAllSpaces, .fullScreenAuxiliary, .transient])
    }

    private func showContextMenu() {
        guard let item = statusItem else { return }
        let menu = buildMenu()
        item.menu = menu
        item.button?.performClick(nil)
        item.menu = nil
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        let openItem = NSMenuItem(title: "Open SwissArmyBar", action: #selector(openMainWindow), keyEquivalent: "")
        openItem.target = self
        menu.addItem(openItem)
        menu.addItem(.separator())

        if let env = appEnvironment {
            let clipboardMenu = NSMenuItem(title: "Clipboard", action: nil, keyEquivalent: "")
            let clipboardSubmenu = NSMenu()
            let limit = max(3, env.appSettings.menuBarClipboardLimit)
            let items = Array(env.clipboardMonitor.items.prefix(limit))
            if items.isEmpty {
                let empty = NSMenuItem(title: "No items yet", action: nil, keyEquivalent: "")
                empty.isEnabled = false
                clipboardSubmenu.addItem(empty)
            } else {
                for item in items {
                    let rawTitle = item.displayTitle
                    let title = rawTitle.count > 40 ? String(rawTitle.prefix(40)) + "…" : rawTitle
                    let menuItem = NSMenuItem(title: title, action: #selector(copyClipboardItem(_:)), keyEquivalent: "")
                    menuItem.target = self
                    menuItem.representedObject = item
                    clipboardSubmenu.addItem(menuItem)
                }
            }
            clipboardMenu.submenu = clipboardSubmenu
            menu.addItem(clipboardMenu)

            let timerMenu = NSMenuItem(title: "Timer", action: nil, keyEquivalent: "")
            let timerSubmenu = NSMenu()
            let startPauseTitle = env.timerStore.isRunning ? "Pause" : "Start"
            let startPauseItem = NSMenuItem(title: startPauseTitle, action: #selector(toggleTimer), keyEquivalent: "")
            startPauseItem.target = self
            timerSubmenu.addItem(startPauseItem)
            let resetItem = NSMenuItem(title: "Reset", action: #selector(resetTimer), keyEquivalent: "")
            resetItem.target = self
            timerSubmenu.addItem(resetItem)
            timerMenu.submenu = timerSubmenu
            menu.addItem(timerMenu)
        }

        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        return menu
    }

    @objc private func openMainWindow() {
        NSRunningApplication.current.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
        if let window = resolveMainWindow() {
            mainWindow = window
            window.collectionBehavior.insert(.moveToActiveSpace)
            window.makeKeyAndOrderFront(nil)
            NSApp.setActivationPolicy(.regular)
            return
        }
        guard let env = appEnvironment else { return }
        let root = ContentView()
            .environmentObject(env.appSettings)
            .environmentObject(env.clipboardSettings)
            .environmentObject(env.clipboardMonitor)
            .environmentObject(env.sidebarSettings)
            .environmentObject(env.timerStore)
            .environmentObject(env.themeStore)
        let hosting = NSHostingController(rootView: root)
        let window = NSWindow(contentViewController: hosting)
        window.setContentSize(NSSize(width: 1024, height: 700))
        window.title = "SwissArmyBar"
        window.level = .normal
        window.collectionBehavior.insert(.moveToActiveSpace)
        window.makeKeyAndOrderFront(nil)
        NSApp.setActivationPolicy(.regular)
        mainWindow = window
    }

    @objc private func copyClipboardItem(_ sender: NSMenuItem) {
        guard let item = sender.representedObject as? ClipboardItem else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        switch item.content {
        case .text(let text):
            pasteboard.setString(text, forType: .string)
        case .image(let data):
            if let image = NSImage(data: data) {
                pasteboard.writeObjects([image])
            }
        }
    }

    @objc private func toggleTimer() {
        guard let timer = appEnvironment?.timerStore else { return }
        if timer.isRunning {
            timer.pause()
        } else {
            timer.start()
        }
    }

    @objc private func resetTimer() {
        appEnvironment?.timerStore.reset()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    private static func formatTime(_ seconds: Int) -> String {
        let minutes = max(0, seconds) / 60
        let remaining = max(0, seconds) % 60
        return String(format: "%02d:%02d", minutes, remaining)
    }
}

private extension AppDelegate {
    @objc func handleWindowVisibilityChange() {
        let anyVisible = NSApp.windows.contains { $0.isVisible }
        NSApp.setActivationPolicy(anyVisible ? .regular : .accessory)
        mainWindow = resolveMainWindow()
    }

    func resolveMainWindow() -> NSWindow? {
        let popoverWindow = popover.contentViewController?.view.window
        if let window = mainWindow, window != popoverWindow, window.level == .normal {
            return window
        }
        return NSApp.windows.first { window in
            window != popoverWindow && window.level == .normal
        }
    }
}

extension Notification.Name {
    static let openMainWindow = Notification.Name("openMainWindow")
}
