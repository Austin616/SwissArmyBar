import AppKit
import Combine
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var appEnvironment: AppEnvironment?

    private var statusItem: NSStatusItem?
    private let popover = NSPopover()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureStatusItem()
        configurePopover()
        bindTimerTitle()
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "SwissArmyBar")
            button.imagePosition = .imageLeading
            button.title = "SAB"
            button.action = #selector(handleStatusItemClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        statusItem = item
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true

        if let env = appEnvironment {
            let view = MenuBarPopoverView()
                .environmentObject(env.appSettings)
                .environmentObject(env.clipboardSettings)
                .environmentObject(env.clipboardMonitor)
                .environmentObject(env.sidebarSettings)
                .environmentObject(env.timerStore)
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
                    button.title = "⏱ \(Self.formatTime(remaining))"
                } else {
                    button.title = "SAB"
                }
            }
            .store(in: &cancellables)
    }

    @objc private func handleStatusItemClick() {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }

    private func togglePopover() {
        guard let button = statusItem?.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
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
                    let title = item.text.count > 40 ? String(item.text.prefix(40)) + "…" : item.text
                    let menuItem = NSMenuItem(title: title, action: #selector(copyClipboardItem(_:)), keyEquivalent: "")
                    menuItem.target = self
                    menuItem.representedObject = item.text
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
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
    }

    @objc private func copyClipboardItem(_ sender: NSMenuItem) {
        guard let text = sender.representedObject as? String else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
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
