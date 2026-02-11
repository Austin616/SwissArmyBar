import SwiftUI
import UniformTypeIdentifiers
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
    @EnvironmentObject private var themeStore: ThemeStore

    @State private var tab: MenuBarTab = .clipboard
    @State private var converterInputURL: URL?
    @State private var converterOutputURL: URL?
    @State private var converterStatus: String?
    @State private var converterOutputType: String = "JPG"
    @State private var isDropTargeted = false

    private var typography: AppTypography { AppTypography(settings: appSettings) }

    private var selectedPreset: ThemePreset {
        let index = min(max(themeStore.selectedThemeIndex, 0), max(themeStore.presets.count - 1, 0))
        return themeStore.presets[index]
    }

    private var isDarkMode: Bool {
        themeStore.isCustomTheme ? themeStore.customThemeIsDark : selectedPreset.isDark
    }

    private var palette: Palette {
        let customColors = CustomColors(
            backgroundTop: themeStore.backgroundTopHSV.color,
            backgroundBottom: themeStore.backgroundBottomHSV.color,
            panelFill: themeStore.panelFillHSV.color,
            cardFill: themeStore.cardFillHSV.color,
            accent: themeStore.accentHSV.color,
            textPrimary: themeStore.textPrimaryHSV.color,
            textSecondary: themeStore.textSecondaryHSV.color
        )
        return Palette(isDark: isDarkMode, customColors: customColors)
    }

    private var progress: Double {
        timerStore.durationMinutes > 0
            ? Double(timerStore.remainingSeconds) / Double(timerStore.durationMinutes * 60)
            : 0
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [palette.backgroundTop, palette.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Picker("", selection: $tab) {
                        ForEach(MenuBarTab.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(palette.accent)
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, 10)
                .background(palette.panelFill.opacity(0.98))

                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 12) {
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
                            .overlay(palette.divider.opacity(0.7))

                        HStack {
                            ThemedButton(title: "Open Window", style: .secondary, size: .small, palette: palette) {
                                NotificationCenter.default.post(name: .openMainWindow, object: nil)
                            }
                            Spacer()
                        }
                    }
                    .padding(14)
                }
                .frame(maxHeight: 420)
            }
        }
        .frame(width: 360)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private var menuClipboard: some View {
        VStack(alignment: .leading, spacing: 8) {
            let limit = max(3, appSettings.menuBarClipboardLimit)
            let items = Array(clipboardMonitor.items.prefix(limit))
            if items.isEmpty {
                Text("No clipboard items yet.")
                    .font(typography.font(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
            } else {
                ForEach(items) { item in
                    Button {
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
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.displayTitle)
                                .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(palette.textPrimary)
                                .lineLimit(1)
                            Text(item.source)
                                .font(typography.font(size: 10, weight: .regular, design: .rounded))
                                .foregroundStyle(palette.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(palette.cardFill.opacity(0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(palette.panelStroke.opacity(0.9), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                ThemedButton(title: "Clear", style: .ghost, size: .small, palette: palette) {
                    clipboardMonitor.clear()
                }
                Spacer()
                Text("\(min(clipboardMonitor.items.count, clipboardSettings.historyLimit)) / \(clipboardSettings.historyLimit)")
                    .font(typography.font(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
            }
        }
    }

    private var menuTimer: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 10) {
                ZStack {
                    ProgressRing(progress: progress, accent: palette.accent, track: palette.panelStroke)
                        .frame(width: 150, height: 150)
                    VStack(spacing: 4) {
                        Text("TIME REMAINING")
                            .font(typography.font(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textSecondary)
                        Text(formatTime(timerStore.remainingSeconds))
                            .font(typography.font(size: 30, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
                            .monospacedDigit()
                    }
                }

                HStack(spacing: 10) {
                    ThemedButton(
                        title: timerStore.isRunning ? "Pause" : "Start",
                        style: .primary,
                        size: .small,
                        palette: palette
                    ) {
                        if timerStore.isRunning {
                            timerStore.pause()
                        } else {
                            timerStore.start()
                        }
                    }
                    ThemedButton(title: "Reset", style: .secondary, size: .small, palette: palette) {
                        timerStore.reset()
                    }
                }
            }
            .frame(maxWidth: .infinity)

            Divider()
                .overlay(palette.divider.opacity(0.7))

            VStack(alignment: .leading, spacing: 10) {
                Text("Duration")
                    .font(typography.font(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(palette.textSecondary)

                NumericInputStepper(
                    value: $timerStore.durationMinutes,
                    range: 1...90,
                    step: 1,
                    suffix: appSettings.timeUnitStyle.label,
                    palette: palette
                )

                HStack(spacing: 8) {
                    MenuDurationChip(title: "15 \(appSettings.timeUnitStyle.label)", isSelected: timerStore.durationMinutes == 15, palette: palette) {
                        timerStore.durationMinutes = 15
                    }
                    MenuDurationChip(title: "25 \(appSettings.timeUnitStyle.label)", isSelected: timerStore.durationMinutes == 25, palette: palette) {
                        timerStore.durationMinutes = 25
                    }
                    MenuDurationChip(title: "50 \(appSettings.timeUnitStyle.label)", isSelected: timerStore.durationMinutes == 50, palette: palette) {
                        timerStore.durationMinutes = 50
                    }
                }

                HStack(spacing: 8) {
                    MenuTogglePill(title: "Auto DND", isOn: $timerStore.autoDNDEnabled, palette: palette)
                    MenuTogglePill(title: "End Sound", isOn: $timerStore.playEndSound, palette: palette)
                }
            }
        }
    }

    private var menuConverter: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(style: StrokeStyle(lineWidth: 1.1, dash: [5, 4]))
                    .foregroundStyle(isDropTargeted ? palette.accent : palette.panelStroke)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(palette.cardFill.opacity(0.9))
                    )

                VStack(spacing: 6) {
                    Text(converterInputURL?.lastPathComponent ?? "Drop an image")
                        .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                    Text("Or choose from Finder")
                        .font(typography.font(size: 10, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                    ThemedButton(title: "Choose File", style: .secondary, size: .small, palette: palette) {
                        openConverterPicker()
                    }
                }
                .padding(.vertical, 10)
            }
            .frame(height: 100)
            .onDrop(of: [UTType.fileURL], isTargeted: $isDropTargeted) { providers in
                guard let provider = providers.first else { return false }
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                    DispatchQueue.main.async {
                        guard let data = item as? Data,
                              let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                        handleConverterURL(url)
                    }
                }
                return true
            }

            HStack {
                Text("Output")
                    .font(typography.font(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
                Spacer()
                Picker("", selection: $converterOutputType) {
                    Text("JPG").tag("JPG")
                    Text("PNG").tag("PNG")
                    Text("HEIC").tag("HEIC")
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .tint(palette.accent)
                .frame(width: 150)
            }

            HStack(spacing: 8) {
                ThemedButton(title: "Export", style: .primary, size: .small, palette: palette) {
                    runQuickConvert()
                }

                if converterOutputURL != nil {
                    ThemedButton(title: "Download", style: .secondary, size: .small, palette: palette) {
                        saveQuickExport()
                    }
                }
            }

            if let url = converterOutputURL {
                HStack(spacing: 6) {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                        .resizable()
                        .frame(width: 16, height: 16)
                        .cornerRadius(3)
                    Text("Drag to save")
                        .font(typography.font(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                    Spacer()
                }
                .onDrag { NSItemProvider(contentsOf: url) ?? NSItemProvider() }
            } else if let converterStatus {
                Text(converterStatus)
                    .font(typography.font(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
            }
        }
    }

    private var menuSettings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Menu bar items: \(appSettings.menuBarClipboardLimit)")
                .font(typography.font(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(palette.textSecondary)
            ThemedButton(title: "Open Settings", style: .secondary, size: .small, palette: palette) {
                NotificationCenter.default.post(name: .openMainWindow, object: nil)
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = max(0, seconds) / 60
        let remaining = max(0, seconds) % 60
        return String(format: "%02d:%02d", minutes, remaining)
    }

    private func openConverterPicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            handleConverterURL(url)
        }
    }

    private func handleConverterURL(_ url: URL) {
        converterInputURL = url
        converterOutputURL = nil
        converterStatus = nil
    }

    private func runQuickConvert() {
        guard let input = converterInputURL else {
            converterStatus = "Choose a file first."
            return
        }
        do {
            converterOutputURL = try ImageConversionService.convert(inputURL: input, outputType: converterOutputType)
            converterStatus = "Converted to \(converterOutputType)."
        } catch ImageConversionError.unsupported {
            converterStatus = "Unsupported format."
        } catch {
            converterStatus = "Conversion failed."
        }
    }

    private func saveQuickExport() {
        guard let url = converterOutputURL else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = url.lastPathComponent
        panel.begin { response in
            guard response == .OK, let destination = panel.url else { return }
            do {
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.copyItem(at: url, to: destination)
                converterStatus = "Saved."
            } catch {
                converterStatus = "Save failed."
            }
        }
    }
}

private struct MenuDurationChip: View {
    let title: String
    let isSelected: Bool
    let palette: Palette
    let action: () -> Void
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(typography.font(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? palette.textPrimary : palette.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? palette.accent.opacity(0.18) : palette.panelFill.opacity(0.5))
                        .overlay(
                            Capsule().stroke(isSelected ? palette.accent : palette.panelStroke, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

private struct MenuTogglePill: View {
    let title: String
    @Binding var isOn: Bool
    let palette: Palette
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(isOn ? palette.accent : palette.panelStroke)
                    .frame(width: 7, height: 7)
                Text(title)
                    .font(typography.font(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(isOn ? palette.textPrimary : palette.textSecondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(palette.panelFill.opacity(0.6))
                    .overlay(
                        Capsule().stroke(isOn ? palette.accent : palette.panelStroke, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
