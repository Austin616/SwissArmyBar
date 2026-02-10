import SwiftUI
import AppKit

private enum MenuBarTab: String, CaseIterable, Identifiable {
    case clipboard = "Clipboard"
    case timer = "Timer"
    case converter = "Converter"
    case settings = "Settings"

    var id: String { rawValue }
}

struct MenuBarPopoverView: View {
    @EnvironmentObject private var clipboardMonitor: ClipboardMonitor
    @EnvironmentObject private var clipboardSettings: ClipboardSettingsStore
    @EnvironmentObject private var timerStore: TimerStore
    @EnvironmentObject private var appSettings: AppSettingsStore

    @State private var tab: MenuBarTab = .clipboard

    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("", selection: $tab) {
                ForEach(MenuBarTab.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.segmented)

            switch tab {
            case .clipboard:
                menuClipboard
            case .timer:
                menuTimer
            case .converter:
                menuConverter
            case .settings:
                menuSettings
            }

            Divider()

            HStack {
                Button("Open Window") {
                    NSApp.activate(ignoringOtherApps: true)
                    NSApp.windows.first?.makeKeyAndOrderFront(nil)
                }
                .buttonStyle(.borderless)
                Spacer()
            }
        }
        .padding(12)
        .frame(width: 320)
    }

    private var menuClipboard: some View {
        VStack(alignment: .leading, spacing: 8) {
            let limit = max(3, appSettings.menuBarClipboardLimit)
            let items = Array(clipboardMonitor.items.prefix(limit))
            if items.isEmpty {
                Text("No clipboard items yet.")
                    .font(typography.font(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items) { item in
                    Button {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(item.text, forType: .string)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.text)
                                .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                                .lineLimit(1)
                            Text(item.source)
                                .font(typography.font(size: 10, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Button("Clear") {
                    clipboardMonitor.clear()
                }
                .buttonStyle(.borderless)
                Spacer()
                Text("\(min(clipboardMonitor.items.count, clipboardSettings.historyLimit)) / \(clipboardSettings.historyLimit)")
                    .font(typography.font(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var menuTimer: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formatTime(timerStore.remainingSeconds))
                .font(typography.font(size: 20, weight: .semibold, design: .rounded))
            HStack(spacing: 8) {
                Button(timerStore.isRunning ? "Pause" : "Start") {
                    if timerStore.isRunning {
                        timerStore.pause()
                    } else {
                        timerStore.start()
                    }
                }
                Button("Reset") {
                    timerStore.reset()
                }
            }
            .buttonStyle(.borderless)
        }
    }

    private var menuConverter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick convert is available in the full window.")
                .font(typography.font(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
            Button("Open Converter") {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.windows.first?.makeKeyAndOrderFront(nil)
            }
            .buttonStyle(.borderless)
        }
    }

    private var menuSettings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Menu bar items: \(appSettings.menuBarClipboardLimit)")
                .font(typography.font(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
            Button("Open Settings") {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.windows.first?.makeKeyAndOrderFront(nil)
            }
            .buttonStyle(.borderless)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = max(0, seconds) / 60
        let remaining = max(0, seconds) % 60
        return String(format: "%02d:%02d", minutes, remaining)
    }
}
