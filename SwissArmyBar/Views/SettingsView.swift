import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeStore: ThemeStore
    let palette: Palette
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InspectorSection(title: "Theme", palette: palette) {
                ThemeModeToggle(isCustomTheme: $themeStore.isCustomTheme, palette: palette) {
                    if themeStore.isCustomTheme {
                        themeStore.customThemeIsDark = themeStore.presets[themeStore.selectedThemeIndex].isDark
                    }
                }

                Text("ACTIVE: \(themeStore.isCustomTheme ? "CUSTOM" : themeStore.presets[themeStore.selectedThemeIndex].name.uppercased())")
                    .font(typography.font(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(palette.textSecondary)

                if !themeStore.isCustomTheme {
                    ThemePresetSection(
                        title: "Dark Presets",
                        presets: themeStore.presets.filter { $0.isDark },
                        selectedPreset: themeStore.presets[themeStore.selectedThemeIndex],
                        palette: palette
                    ) { preset in
                        themeStore.selectPreset(preset)
                    }
                    .transition(.opacity.combined(with: .move(edge: .leading)))

                    ThemePresetSection(
                        title: "Light Presets",
                        presets: themeStore.presets.filter { !$0.isDark },
                        selectedPreset: themeStore.presets[themeStore.selectedThemeIndex],
                        palette: palette
                    ) { preset in
                        themeStore.selectPreset(preset)
                    }
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }

            InspectorSection(title: "Interface", palette: palette) {
                HStack {
                    Text("Time Units")
                        .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                    Spacer()
                    Picker("", selection: Binding(
                        get: { appSettings.timeUnitStyle },
                        set: { appSettings.timeUnitStyle = $0 }
                    )) {
                        Text("Short").tag(TimeUnitStyle.short)
                        Text("Long").tag(TimeUnitStyle.long)
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                    .tint(palette.accent)
                }

                InspectorDivider(palette: palette)

                HStack {
                    Text("Font Size")
                        .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                    Spacer()
                    NumericInputStepper(
                        value: $appSettings.fontScalePercent,
                        range: 80...130,
                        step: 1,
                        suffix: "%",
                        palette: palette
                    )
                }

                InspectorDivider(palette: palette)

                HStack {
                    Text("Font")
                        .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                    Spacer()
                    Picker("", selection: Binding(
                        get: { appSettings.fontChoice },
                        set: { appSettings.fontChoice = $0 }
                    )) {
                        ForEach(AppFontChoice.allCases) { choice in
                            Text(choice.displayName).tag(choice)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(width: 170)
                }
                Text("Preview: The quick brown fox 123")
                    .font(typography.font(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)

                InspectorDivider(palette: palette)

                HStack {
                    Text("Menu Bar Items")
                        .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                    Spacer()
                    NumericInputStepper(
                        value: $appSettings.menuBarClipboardLimit,
                        range: 3...20,
                        step: 1,
                        suffix: "items",
                        palette: palette
                    )
                }
            }

            if themeStore.isCustomTheme {
                InspectorSection(title: "Palette Editor", palette: palette) {
                    HStack {
                        Text("MODE")
                            .font(typography.font(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textSecondary)
                        Spacer()
                        Picker("", selection: $themeStore.customThemeIsDark) {
                            Text("Dark").tag(true)
                            Text("Light").tag(false)
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                        .tint(palette.accent)
                    }
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Accent", hsv: $themeStore.accentHSV, palette: palette)
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Text Primary", hsv: $themeStore.textPrimaryHSV, palette: palette)
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Text Secondary", hsv: $themeStore.textSecondaryHSV, palette: palette)
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Background Top", hsv: $themeStore.backgroundTopHSV, palette: palette)
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Background Bottom", hsv: $themeStore.backgroundBottomHSV, palette: palette)
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Panel", hsv: $themeStore.panelFillHSV, palette: palette)
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Card", hsv: $themeStore.cardFillHSV, palette: palette)
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))

                HStack(spacing: 12) {
                    ThemedButton(title: "Revert to Preset", style: .secondary, size: .small, palette: palette) {
                        themeStore.applyPreset(themeStore.presets[themeStore.selectedThemeIndex])
                        themeStore.isCustomTheme = false
                    }

                    Text("Custom palette changes apply immediately.")
                        .font(typography.font(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                }
            }
        }
        .animation(.easeInOut(duration: 0.22), value: themeStore.isCustomTheme)
    }
}

struct ThemePresetSection: View {
    let title: String
    let presets: [ThemePreset]
    let selectedPreset: ThemePreset
    let palette: Palette
    let onSelect: (ThemePreset) -> Void
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(typography.font(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(palette.textSecondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(presets) { preset in
                    ThemePill(
                        preset: preset,
                        isSelected: selectedPreset.id == preset.id,
                        palette: palette
                    ) {
                        onSelect(preset)
                    }
                }
            }
        }
    }
}

struct ThemePill: View {
    let preset: ThemePreset
    let isSelected: Bool
    let palette: Palette
    let action: () -> Void
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        Button(action: action) {
            Text(preset.name.lowercased())
                .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(preset.accent.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(preset.backgroundTop.color)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(
                                    isSelected ? preset.accent.color.opacity(0.8) : palette.panelStroke,
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                        .shadow(color: Color.black.opacity(preset.isDark ? 0.28 : 0.08), radius: 2, x: 0, y: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct ThemeModeToggle: View {
    @Binding var isCustomTheme: Bool
    let palette: Palette
    let onChange: () -> Void
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        HStack {
            Text("THEME")
                .font(typography.font(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(palette.textSecondary)
            Spacer()
            Picker("", selection: $isCustomTheme) {
                Text("Presets").tag(false)
                Text("Custom").tag(true)
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .frame(width: 200)
            .tint(palette.accent)
            .onChange(of: isCustomTheme) { _, _ in
                withAnimation(.easeInOut(duration: 0.22)) {
                    onChange()
                }
            }
        }
    }
}

struct ColorRow: View {
    let title: String
    @Binding var hsv: HSVColor
    let palette: Palette
    @State private var isPickerPresented = false
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        HStack(spacing: 10) {
            Text(title.uppercased())
                .font(typography.font(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(palette.textSecondary)
            Spacer()
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(hsv.color)
                .frame(width: 18, height: 18)
                .overlay(
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
            Text(hsv.hex)
                .font(typography.font(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(palette.textPrimary)
            ThemedButton(title: "Edit", style: .secondary, size: .small, palette: palette) {
                isPickerPresented = true
            }
            .popover(isPresented: $isPickerPresented, arrowEdge: .trailing) {
                ColorEditorPopover(title: title, hsv: $hsv, palette: palette)
            }
        }
    }
}

struct ColorEditorPopover: View {
    let title: String
    @Binding var hsv: HSVColor
    let palette: Palette
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(title.uppercased()) COLOR")
                .font(typography.font(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(palette.textPrimary)

            HStack(alignment: .top, spacing: 14) {
                HueArcPicker(hue: $hsv.h, accent: hsv.color)
                    .frame(width: 140, height: 140)
                SaturationValueSquare(
                    hue: hsv.h,
                    saturation: $hsv.s,
                    value: $hsv.v
                )
                .frame(width: 160, height: 160)
            }

            HStack {
                Text("HEX")
                    .font(typography.font(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(palette.textSecondary)
                Text(hsv.hex)
                    .font(typography.font(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(palette.textPrimary)
                Spacer()
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(hsv.color)
                    .frame(width: 30, height: 18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(palette.panelStroke, lineWidth: 1)
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.panelFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
        )
        .frame(width: 360)
    }
}

struct HueArcPicker: View {
    @Binding var hue: Double
    let accent: Color

    private let ringWidth: CGFloat = 14
    private let startAngle = Angle(degrees: 135)
    private let sweepAngle: Double = 270

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size / 2 - ringWidth
            let angle = startAngle.radians + (hue.clamped(to: 0...1) * sweepAngle.degreesToRadians)
            let knobPosition = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )

            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: stride(from: 0.0, through: 1.0, by: 0.1).map {
                                Color(hue: $0, saturation: 1, brightness: 1)
                            }),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                    )
                    .rotationEffect(startAngle)

                Circle()
                    .strokeBorder(Color.white.opacity(0.04), lineWidth: 1)

                Circle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: ringWidth + 6, height: ringWidth + 6)
                    .position(knobPosition)

                Circle()
                    .fill(Color.white)
                    .frame(width: ringWidth - 2, height: ringWidth - 2)
                    .position(knobPosition)
                    .shadow(color: accent.opacity(0.5), radius: 4, x: 0, y: 0)
            }
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let dx = value.location.x - center.x
                        let dy = value.location.y - center.y
                        var angle = atan2(dy, dx)
                        if angle < 0 { angle += 2 * .pi }

                        let start = startAngle.radians
                        let total = sweepAngle.degreesToRadians
                        var adjusted = angle
                        if adjusted < start { adjusted += 2 * .pi }
                        let clamped = min(max(adjusted, start), start + total)
                        hue = (clamped - start) / total
                    }
            )
        }
    }
}

struct SaturationValueSquare: View {
    let hue: Double
    @Binding var saturation: Double
    @Binding var value: Double

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let knobX = size.width * saturation.clamped(to: 0...1)
            let knobY = size.height * (1 - value.clamped(to: 0...1))

            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color(hue: hue, saturation: 1, brightness: 1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0), Color.black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .background(Circle().fill(Color.black.opacity(0.35)))
                    .frame(width: 14, height: 14)
                    .position(x: knobX, y: knobY)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let clampedX = min(max(0, gesture.location.x), size.width)
                        let clampedY = min(max(0, gesture.location.y), size.height)
                        saturation = Double(clampedX / size.width)
                        value = Double(1 - (clampedY / size.height))
                    }
            )
        }
    }
}
