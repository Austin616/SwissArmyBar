import SwiftUI

struct ContentView: View {
    @State private var selectedTool: Tool = .clipboard
    @State private var isSidebarCollapsed = false
    @State private var isSidebarExpandedInCompact = false
    @State private var isInfoPresented = false
    @StateObject private var themeStore = ThemeStore(presets: ThemeCatalog.presets)
    @StateObject private var clipboardSettings: ClipboardSettingsStore
    @StateObject private var clipboardMonitor: ClipboardMonitor
    @StateObject private var sidebarSettings = SidebarSettingsStore()
    @State private var installedApps: [InstalledApp] = []

    @AppStorage("timerDurationMinutes") private var timerDurationMinutes: Int = 25
    @State private var timerRemainingSeconds = 0
    @AppStorage("timerAutoDNDEnabled") private var autoDNDEnabled = true
    @AppStorage("timerPlayEndSound") private var playEndSound = true

    @State private var detectedInputType = "PNG"
    @State private var selectedOutputType = "JPG"
    private let supportedOutputTypes = ["JPG", "PNG", "HEIC", "WEBP"]

    init() {
        let settings = ClipboardSettingsStore()
        _clipboardSettings = StateObject(wrappedValue: settings)
        _clipboardMonitor = StateObject(wrappedValue: ClipboardMonitor(settings: settings))
    }

    var body: some View {
        let currentIsDark = themeStore.isCustomTheme
            ? themeStore.customThemeIsDark
            : ThemeCatalog.presets[themeStore.selectedThemeIndex].isDark
        let customColors = CustomColors(
            backgroundTop: themeStore.backgroundTopHSV.color,
            backgroundBottom: themeStore.backgroundBottomHSV.color,
            panelFill: themeStore.panelFillHSV.color,
            cardFill: themeStore.cardFillHSV.color,
            accent: themeStore.accentHSV.color,
            textPrimary: themeStore.textPrimaryHSV.color,
            textSecondary: themeStore.textSecondaryHSV.color
        )
        let palette = Palette(isDark: currentIsDark, customColors: customColors)

        GeometryReader { proxy in
            let isCompact = proxy.size.width < 980
            let effectiveSidebarCollapsed = isCompact ? !isSidebarExpandedInCompact : isSidebarCollapsed

            ZStack {
                LinearGradient(
                    colors: [palette.backgroundTop, palette.backgroundBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                TerminalGridBackground(lineColor: palette.divider, glow: palette.glow)
                    .ignoresSafeArea()

                HStack(spacing: isCompact ? 14 : 20) {
                    SidebarView(
                        selectedTool: $selectedTool,
                        settings: sidebarSettings,
                        isCollapsed: effectiveSidebarCollapsed,
                        palette: palette
                    )
                    .animation(.easeInOut(duration: 0.2), value: effectiveSidebarCollapsed)
                    detailArea(palette: palette, isCompact: isCompact, isSidebarCollapsed: effectiveSidebarCollapsed)
                }
                .padding(isCompact ? 16 : 24)
            }
            .preferredColorScheme(currentIsDark ? .dark : .light)
        }
        .frame(minWidth: 960, minHeight: 620)
        .task {
            if timerDurationMinutes < 5 || timerDurationMinutes > 90 {
                timerDurationMinutes = 25
            }
            timerRemainingSeconds = timerDurationMinutes * 60
            let apps = await Task.detached {
                InstalledAppProvider.loadInstalledApps()
            }.value
            installedApps = apps
        }
    }

    private func detailArea(palette: Palette, isCompact: Bool, isSidebarCollapsed: Bool) -> some View {
        Group {
            if isCompact {
                ScrollView {
                    detailContent(palette: palette, isCompact: isCompact, isSidebarCollapsed: isSidebarCollapsed)
                }
            } else {
                detailContent(palette: palette, isCompact: isCompact, isSidebarCollapsed: isSidebarCollapsed)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.panelFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
        )
        .sheet(isPresented: $isInfoPresented) {
            InfoSheetView(palette: palette)
        }
    }

    private func detailContent(palette: Palette, isCompact: Bool, isSidebarCollapsed: Bool) -> some View {
        VStack(alignment: .leading, spacing: isCompact ? 16 : 20) {
            HStack(alignment: .center, spacing: 12) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if isCompact {
                            isSidebarExpandedInCompact.toggle()
                        } else {
                            self.isSidebarCollapsed.toggle()
                        }
                    }
                } label: {
                    Image(systemName: isSidebarCollapsed ? "sidebar.trailing" : "sidebar.leading")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(palette.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(palette.panelFill.opacity(0.6))
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut("s", modifiers: [.command])

                VStack(alignment: .leading, spacing: 6) {
                    Text(selectedTool.rawValue)
                        .font(.system(size: 24, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textPrimary)
                    Text(selectedTool.subtitle)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                }
                Spacer()
                Button {
                    isInfoPresented = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(palette.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(palette.panelFill.opacity(0.6))
                        )
                }
                .buttonStyle(.plain)
            }

            Divider()
                .overlay(palette.divider)

            toolView(palette: palette, isCompact: isCompact)

            if !isCompact {
                Spacer()
            }
        }
        .padding(isCompact ? 18 : 24)
    }

    @ViewBuilder
    private func toolView(palette: Palette, isCompact: Bool) -> some View {
        switch selectedTool {
            case .clipboard:
                ClipboardView(
                    monitor: clipboardMonitor,
                    settings: clipboardSettings,
                    installedApps: installedApps,
                    isCompact: isCompact,
                    palette: palette
                )
        case .focusTimer:
            FocusTimerView(
                timerDurationMinutes: $timerDurationMinutes,
                timerRemainingSeconds: $timerRemainingSeconds,
                autoDNDEnabled: $autoDNDEnabled,
                playEndSound: $playEndSound,
                palette: palette
            )
        case .fileConverter:
            FileConverterView(
                detectedInputType: $detectedInputType,
                selectedOutputType: $selectedOutputType,
                supportedOutputTypes: supportedOutputTypes,
                isCompact: isCompact,
                palette: palette
            )
        case .settings:
            SettingsView(
                themeStore: themeStore,
                palette: palette
            )
        }
    }
}

#Preview {
    ContentView()
}
