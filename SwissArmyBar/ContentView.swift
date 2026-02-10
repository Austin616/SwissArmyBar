import SwiftUI

struct ContentView: View {
    @State private var selectedTool: Tool = .clipboard
    @State private var isSidebarCollapsed = false
    @State private var isInfoPresented = false

    @State private var selectedThemeIndex = 0
    @State private var isCustomTheme = false
    @State private var customThemeIsDark = true
    @State private var backgroundTopHSV = HSVColor.fromRGB(0.02, 0.03, 0.05)
    @State private var backgroundBottomHSV = HSVColor.fromRGB(0.05, 0.07, 0.10)
    @State private var panelFillHSV = HSVColor.fromRGB(0.05, 0.07, 0.10)
    @State private var cardFillHSV = HSVColor.fromRGB(0.07, 0.09, 0.13)
    @State private var accentHSV = HSVColor.fromRGB(0.20, 0.94, 0.52)
    @State private var textPrimaryHSV = HSVColor.fromRGB(0.90, 0.96, 0.93)
    @State private var textSecondaryHSV = HSVColor.fromRGB(0.54, 0.63, 0.60)

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

    private let themePresets: [ThemePreset] = [
        ThemePreset(
            name: "Terminal Green",
            isDark: true,
            backgroundTop: HSVColor.fromRGB(0.02, 0.03, 0.05),
            backgroundBottom: HSVColor.fromRGB(0.05, 0.07, 0.10),
            panelFill: HSVColor.fromRGB(0.05, 0.07, 0.10),
            cardFill: HSVColor.fromRGB(0.07, 0.09, 0.13),
            accent: HSVColor.fromRGB(0.20, 0.94, 0.52),
            textPrimary: HSVColor.fromRGB(0.90, 0.96, 0.93),
            textSecondary: HSVColor.fromRGB(0.54, 0.63, 0.60)
        ),
        ThemePreset(
            name: "Nord",
            isDark: true,
            backgroundTop: HSVColor.fromRGB(0.10, 0.12, 0.16),
            backgroundBottom: HSVColor.fromRGB(0.14, 0.17, 0.22),
            panelFill: HSVColor.fromRGB(0.12, 0.15, 0.20),
            cardFill: HSVColor.fromRGB(0.16, 0.19, 0.25),
            accent: HSVColor.fromRGB(0.53, 0.75, 0.83),
            textPrimary: HSVColor.fromRGB(0.90, 0.92, 0.94),
            textSecondary: HSVColor.fromRGB(0.62, 0.67, 0.72)
        ),
        ThemePreset(
            name: "Amber CRT",
            isDark: true,
            backgroundTop: HSVColor.fromRGB(0.07, 0.06, 0.03),
            backgroundBottom: HSVColor.fromRGB(0.10, 0.09, 0.05),
            panelFill: HSVColor.fromRGB(0.10, 0.09, 0.05),
            cardFill: HSVColor.fromRGB(0.13, 0.12, 0.07),
            accent: HSVColor.fromRGB(0.98, 0.74, 0.18),
            textPrimary: HSVColor.fromRGB(0.96, 0.93, 0.85),
            textSecondary: HSVColor.fromRGB(0.70, 0.62, 0.45)
        ),
        ThemePreset(
            name: "Violet Neon",
            isDark: true,
            backgroundTop: HSVColor.fromRGB(0.05, 0.04, 0.08),
            backgroundBottom: HSVColor.fromRGB(0.08, 0.06, 0.12),
            panelFill: HSVColor.fromRGB(0.08, 0.06, 0.12),
            cardFill: HSVColor.fromRGB(0.11, 0.09, 0.16),
            accent: HSVColor.fromRGB(0.62, 0.46, 0.96),
            textPrimary: HSVColor.fromRGB(0.92, 0.90, 0.96),
            textSecondary: HSVColor.fromRGB(0.62, 0.58, 0.72)
        ),
        ThemePreset(
            name: "Cobalt",
            isDark: true,
            backgroundTop: HSVColor.fromRGB(0.03, 0.05, 0.09),
            backgroundBottom: HSVColor.fromRGB(0.05, 0.08, 0.13),
            panelFill: HSVColor.fromRGB(0.05, 0.08, 0.13),
            cardFill: HSVColor.fromRGB(0.08, 0.11, 0.17),
            accent: HSVColor.fromRGB(0.29, 0.69, 0.98),
            textPrimary: HSVColor.fromRGB(0.90, 0.94, 0.98),
            textSecondary: HSVColor.fromRGB(0.58, 0.62, 0.70)
        ),
        ThemePreset(
            name: "Paper",
            isDark: false,
            backgroundTop: HSVColor.fromRGB(0.98, 0.97, 0.95),
            backgroundBottom: HSVColor.fromRGB(0.94, 0.92, 0.89),
            panelFill: HSVColor.fromRGB(0.97, 0.96, 0.94),
            cardFill: HSVColor.fromRGB(1.00, 0.99, 0.97),
            accent: HSVColor.fromRGB(0.75, 0.45, 0.20),
            textPrimary: HSVColor.fromRGB(0.16, 0.15, 0.14),
            textSecondary: HSVColor.fromRGB(0.36, 0.34, 0.32)
        ),
        ThemePreset(
            name: "Nord Light",
            isDark: false,
            backgroundTop: HSVColor.fromRGB(0.93, 0.95, 0.98),
            backgroundBottom: HSVColor.fromRGB(0.88, 0.91, 0.96),
            panelFill: HSVColor.fromRGB(0.92, 0.94, 0.98),
            cardFill: HSVColor.fromRGB(0.97, 0.98, 1.00),
            accent: HSVColor.fromRGB(0.25, 0.55, 0.86),
            textPrimary: HSVColor.fromRGB(0.16, 0.20, 0.26),
            textSecondary: HSVColor.fromRGB(0.36, 0.42, 0.50)
        ),
        ThemePreset(
            name: "Rose Dawn",
            isDark: false,
            backgroundTop: HSVColor.fromRGB(0.99, 0.96, 0.97),
            backgroundBottom: HSVColor.fromRGB(0.96, 0.92, 0.94),
            panelFill: HSVColor.fromRGB(0.98, 0.95, 0.96),
            cardFill: HSVColor.fromRGB(1.00, 0.98, 0.99),
            accent: HSVColor.fromRGB(0.88, 0.40, 0.52),
            textPrimary: HSVColor.fromRGB(0.22, 0.18, 0.20),
            textSecondary: HSVColor.fromRGB(0.44, 0.36, 0.40)
        ),
        ThemePreset(
            name: "Mint",
            isDark: false,
            backgroundTop: HSVColor.fromRGB(0.95, 0.99, 0.97),
            backgroundBottom: HSVColor.fromRGB(0.90, 0.96, 0.93),
            panelFill: HSVColor.fromRGB(0.94, 0.98, 0.96),
            cardFill: HSVColor.fromRGB(0.99, 1.00, 0.99),
            accent: HSVColor.fromRGB(0.20, 0.62, 0.45),
            textPrimary: HSVColor.fromRGB(0.16, 0.20, 0.18),
            textSecondary: HSVColor.fromRGB(0.34, 0.40, 0.36)
        ),
        ThemePreset(
            name: "Sunrise",
            isDark: false,
            backgroundTop: HSVColor.fromRGB(0.99, 0.97, 0.92),
            backgroundBottom: HSVColor.fromRGB(0.96, 0.93, 0.86),
            panelFill: HSVColor.fromRGB(0.98, 0.95, 0.90),
            cardFill: HSVColor.fromRGB(1.00, 0.98, 0.94),
            accent: HSVColor.fromRGB(0.90, 0.58, 0.18),
            textPrimary: HSVColor.fromRGB(0.20, 0.18, 0.16),
            textSecondary: HSVColor.fromRGB(0.44, 0.38, 0.34)
        )
    ]

    var body: some View {
        let currentIsDark = isCustomTheme ? customThemeIsDark : themePresets[selectedThemeIndex].isDark
        let customColors = CustomColors(
            backgroundTop: backgroundTopHSV.color,
            backgroundBottom: backgroundBottomHSV.color,
            panelFill: panelFillHSV.color,
            cardFill: cardFillHSV.color,
            accent: accentHSV.color,
            textPrimary: textPrimaryHSV.color,
            textSecondary: textSecondaryHSV.color
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
                    isCustomTheme: $isCustomTheme,
                    selectedThemeIndex: $selectedThemeIndex,
                    customThemeIsDark: $customThemeIsDark,
                    backgroundTopHSV: $backgroundTopHSV,
                    backgroundBottomHSV: $backgroundBottomHSV,
                    panelFillHSV: $panelFillHSV,
                    cardFillHSV: $cardFillHSV,
                    accentHSV: $accentHSV,
                    textPrimaryHSV: $textPrimaryHSV,
                    textSecondaryHSV: $textSecondaryHSV,
                    themePresets: themePresets,
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
