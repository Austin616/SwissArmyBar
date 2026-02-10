import SwiftUI

struct ContentView: View {
    @State private var selectedTool: Tool = .clipboard
    @State private var isSidebarCollapsed = false
    @State private var isInfoPresented = false
    @StateObject private var themeStore = ThemeStore(presets: ThemeCatalog.presets)

    @State private var clipboardHistoryLimit = 8
    @State private var clipboardItems: [ClipboardItem] = [
        ClipboardItem(text: "Ship MVP build by Friday", source: "Notes", timestamp: "2m ago"),
        ClipboardItem(text: "https://docs.swissarmybar.dev/cli", source: "Safari", timestamp: "6m ago"),
        ClipboardItem(text: "config.json updated output path", source: "Xcode", timestamp: "9m ago"),
        ClipboardItem(text: "Focus block at 2pm", source: "Calendar", timestamp: "12m ago"),
        ClipboardItem(text: "Signed release build", source: "Terminal", timestamp: "18m ago")
    ]

    @State private var timerDurationMinutes: Double = 25
    @State private var timerRemainingSeconds = 25 * 60
    @State private var autoDNDEnabled = true
    @State private var playEndSound = true

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

        ZStack {
            LinearGradient(
                colors: [palette.backgroundTop, palette.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TerminalGridBackground(lineColor: palette.divider, glow: palette.glow)
                .ignoresSafeArea()

            HStack(spacing: 20) {
                SidebarView(
                    selectedTool: $selectedTool,
                    isCollapsed: isSidebarCollapsed,
                    palette: palette
                )
                .animation(.easeInOut(duration: 0.2), value: isSidebarCollapsed)
                detailArea(palette: palette)
            }
            .padding(24)
        }
        .preferredColorScheme(currentIsDark ? .dark : .light)
        .frame(minWidth: 920, minHeight: 600)
    }

    private func detailArea(palette: Palette) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 12) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSidebarCollapsed.toggle()
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

            switch selectedTool {
            case .clipboard:
                ClipboardView(
                    clipboardItems: $clipboardItems,
                    clipboardHistoryLimit: $clipboardHistoryLimit,
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
                    palette: palette
                )
            case .settings:
                SettingsView(
                    themeStore: themeStore,
                    palette: palette
                )
            }

            Spacer()
        }
        .padding(24)
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
}

#Preview {
    ContentView()
}
