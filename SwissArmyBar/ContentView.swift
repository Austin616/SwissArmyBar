import SwiftUI

struct ContentView: View {
    @State private var selectedTool: Tool = .clipboard
    @State private var isSidebarCollapsed = false
    @State private var isSidebarExpandedInCompact = false
    @State private var isInfoPresented = false
    @EnvironmentObject private var appSettings: AppSettingsStore
    @EnvironmentObject private var clipboardSettings: ClipboardSettingsStore
    @EnvironmentObject private var clipboardMonitor: ClipboardMonitor
    @EnvironmentObject private var sidebarSettings: SidebarSettingsStore
    @EnvironmentObject private var timerStore: TimerStore
    @EnvironmentObject private var themeStore: ThemeStore
    @State private var installedApps: [InstalledApp] = []

    @State private var detectedInputType = "PNG"
    @State private var selectedOutputType = "JPG"
    private let supportedOutputTypes = ["JPG", "PNG", "HEIC", "WEBP"]

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
            let apps = await Task.detached {
                InstalledAppProvider.loadInstalledApps()
            }.value
            installedApps = apps
        }
    }

    private func detailArea(palette: Palette, isCompact: Bool, isSidebarCollapsed: Bool) -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            detailContent(palette: palette, isCompact: isCompact, isSidebarCollapsed: isSidebarCollapsed)
        }
        .alwaysShowScrollIndicators()
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
        let typography = AppTypography(settings: appSettings)
        return VStack(alignment: .leading, spacing: isCompact ? 16 : 20) {
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
                        .font(typography.font(size: 24, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textPrimary)
                    Text(selectedTool.subtitle)
                        .font(typography.font(size: 12, weight: .regular, design: .monospaced))
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
                    timer: timerStore,
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
    let clipboardSettings = ClipboardSettingsStore()
    ContentView()
        .environmentObject(AppSettingsStore())
        .environmentObject(clipboardSettings)
        .environmentObject(ClipboardMonitor(settings: clipboardSettings))
        .environmentObject(SidebarSettingsStore())
        .environmentObject(TimerStore())
        .environmentObject(ThemeStore(presets: ThemeCatalog.presets))
}
