import Foundation

final class ThemeStore: ObservableObject {
    let presets: [ThemePreset]
    private let defaults: UserDefaults
    private let storageKey = "themePreferences.v1"
    private var isLoaded = false

    @Published var selectedThemeIndex: Int {
        didSet { save() }
    }
    @Published var isCustomTheme: Bool {
        didSet { save() }
    }
    @Published var customThemeIsDark: Bool {
        didSet { save() }
    }
    @Published var backgroundTopHSV: HSVColor {
        didSet { save() }
    }
    @Published var backgroundBottomHSV: HSVColor {
        didSet { save() }
    }
    @Published var panelFillHSV: HSVColor {
        didSet { save() }
    }
    @Published var cardFillHSV: HSVColor {
        didSet { save() }
    }
    @Published var accentHSV: HSVColor {
        didSet { save() }
    }
    @Published var textPrimaryHSV: HSVColor {
        didSet { save() }
    }
    @Published var textSecondaryHSV: HSVColor {
        didSet { save() }
    }

    init(presets: [ThemePreset], defaults: UserDefaults = .standard) {
        self.presets = presets
        self.defaults = defaults

        let fallback = presets.first ?? ThemePreset(
            name: "Default",
            isDark: true,
            backgroundTop: HSVColor.fromRGB(0.02, 0.03, 0.05),
            backgroundBottom: HSVColor.fromRGB(0.05, 0.07, 0.10),
            panelFill: HSVColor.fromRGB(0.05, 0.07, 0.10),
            cardFill: HSVColor.fromRGB(0.07, 0.09, 0.13),
            accent: HSVColor.fromRGB(0.20, 0.94, 0.52),
            textPrimary: HSVColor.fromRGB(0.90, 0.96, 0.93),
            textSecondary: HSVColor.fromRGB(0.54, 0.63, 0.60)
        )

        if let data = defaults.data(forKey: storageKey),
           let prefs = try? JSONDecoder().decode(ThemePreferences.self, from: data) {
            let boundedIndex = min(max(0, prefs.selectedThemeIndex), presets.count - 1)
            selectedThemeIndex = boundedIndex
            isCustomTheme = prefs.isCustomTheme
            customThemeIsDark = prefs.customThemeIsDark

            if prefs.isCustomTheme {
                backgroundTopHSV = prefs.backgroundTopHSV
                backgroundBottomHSV = prefs.backgroundBottomHSV
                panelFillHSV = prefs.panelFillHSV
                cardFillHSV = prefs.cardFillHSV
                accentHSV = prefs.accentHSV
                textPrimaryHSV = prefs.textPrimaryHSV
                textSecondaryHSV = prefs.textSecondaryHSV
            } else {
                let preset = presets[boundedIndex]
                backgroundTopHSV = preset.backgroundTop
                backgroundBottomHSV = preset.backgroundBottom
                panelFillHSV = preset.panelFill
                cardFillHSV = preset.cardFill
                accentHSV = preset.accent
                textPrimaryHSV = preset.textPrimary
                textSecondaryHSV = preset.textSecondary
                customThemeIsDark = preset.isDark
            }
        } else {
            selectedThemeIndex = 0
            isCustomTheme = false
            customThemeIsDark = fallback.isDark
            backgroundTopHSV = fallback.backgroundTop
            backgroundBottomHSV = fallback.backgroundBottom
            panelFillHSV = fallback.panelFill
            cardFillHSV = fallback.cardFill
            accentHSV = fallback.accent
            textPrimaryHSV = fallback.textPrimary
            textSecondaryHSV = fallback.textSecondary
        }

        isLoaded = true
    }

    func selectPreset(_ preset: ThemePreset) {
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            selectedThemeIndex = index
        }
        isCustomTheme = false
        applyPreset(preset)
    }

    func applyPreset(_ preset: ThemePreset) {
        backgroundTopHSV = preset.backgroundTop
        backgroundBottomHSV = preset.backgroundBottom
        panelFillHSV = preset.panelFill
        cardFillHSV = preset.cardFill
        accentHSV = preset.accent
        textPrimaryHSV = preset.textPrimary
        textSecondaryHSV = preset.textSecondary
        customThemeIsDark = preset.isDark
    }

    private func save() {
        guard isLoaded else { return }
        let prefs = ThemePreferences(
            selectedThemeIndex: selectedThemeIndex,
            isCustomTheme: isCustomTheme,
            customThemeIsDark: customThemeIsDark,
            backgroundTopHSV: backgroundTopHSV,
            backgroundBottomHSV: backgroundBottomHSV,
            panelFillHSV: panelFillHSV,
            cardFillHSV: cardFillHSV,
            accentHSV: accentHSV,
            textPrimaryHSV: textPrimaryHSV,
            textSecondaryHSV: textSecondaryHSV
        )
        if let data = try? JSONEncoder().encode(prefs) {
            defaults.set(data, forKey: storageKey)
        }
    }
}

private struct ThemePreferences: Codable {
    let selectedThemeIndex: Int
    let isCustomTheme: Bool
    let customThemeIsDark: Bool
    let backgroundTopHSV: HSVColor
    let backgroundBottomHSV: HSVColor
    let panelFillHSV: HSVColor
    let cardFillHSV: HSVColor
    let accentHSV: HSVColor
    let textPrimaryHSV: HSVColor
    let textSecondaryHSV: HSVColor
}
