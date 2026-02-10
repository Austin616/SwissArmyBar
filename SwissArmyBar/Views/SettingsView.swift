import SwiftUI

struct SettingsView: View {
    @Binding var isCustomTheme: Bool
    @Binding var selectedThemeIndex: Int
    @Binding var customThemeIsDark: Bool
    @Binding var backgroundTopHSV: HSVColor
    @Binding var backgroundBottomHSV: HSVColor
    @Binding var panelFillHSV: HSVColor
    @Binding var cardFillHSV: HSVColor
    @Binding var accentHSV: HSVColor
    @Binding var textPrimaryHSV: HSVColor
    @Binding var textSecondaryHSV: HSVColor
    let themePresets: [ThemePreset]
    let palette: Palette

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InspectorSection(title: "Theme", palette: palette) {
                ThemeModeToggle(isCustomTheme: $isCustomTheme, palette: palette) {
                    if isCustomTheme {
                        customThemeIsDark = themePresets[selectedThemeIndex].isDark
                    }
                }

                Text("ACTIVE: \(isCustomTheme ? "CUSTOM" : themePresets[selectedThemeIndex].name.uppercased())")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(palette.textSecondary)

                if !isCustomTheme {
                    ThemePresetSection(
                        title: "Dark Presets",
                        presets: themePresets.filter { $0.isDark },
                        selectedPreset: themePresets[selectedThemeIndex],
                        palette: palette
                    ) { preset in
                        if let index = themePresets.firstIndex(where: { $0.id == preset.id }) {
                            selectedThemeIndex = index
                        }
                        isCustomTheme = false
                        applyPreset(preset)
                    }

                    ThemePresetSection(
                        title: "Light Presets",
                        presets: themePresets.filter { !$0.isDark },
                        selectedPreset: themePresets[selectedThemeIndex],
                        palette: palette
                    ) { preset in
                        if let index = themePresets.firstIndex(where: { $0.id == preset.id }) {
                            selectedThemeIndex = index
                        }
                        isCustomTheme = false
                        applyPreset(preset)
                    }
                }
            }

            if isCustomTheme {
                InspectorSection(title: "Palette Editor", palette: palette) {
                    HStack {
                        Text("MODE")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textSecondary)
                        Spacer()
                        Picker("", selection: $customThemeIsDark) {
                            Text("Dark").tag(true)
                            Text("Light").tag(false)
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                    }
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Accent", hsv: $accentHSV, palette: palette)
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Text Primary", hsv: $textPrimaryHSV, palette: palette)
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Text Secondary", hsv: $textSecondaryHSV, palette: palette)
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Background Top", hsv: $backgroundTopHSV, palette: palette)
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Background Bottom", hsv: $backgroundBottomHSV, palette: palette)
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Panel", hsv: $panelFillHSV, palette: palette)
                    InspectorDivider(palette: palette)
                    ColorRow(title: "Card", hsv: $cardFillHSV, palette: palette)
                }

                HStack(spacing: 12) {
                    Button("Revert to Preset") {
                        applyPreset(themePresets[selectedThemeIndex])
                        isCustomTheme = false
                    }
                    .buttonStyle(.bordered)
                    .tint(palette.textSecondary)

                    Text("Custom palette changes apply immediately.")
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                }
            }
        }
    }

    private func applyPreset(_ preset: ThemePreset) {
        backgroundTopHSV = preset.backgroundTop
        backgroundBottomHSV = preset.backgroundBottom
        panelFillHSV = preset.panelFill
        cardFillHSV = preset.cardFill
        accentHSV = preset.accent
        textPrimaryHSV = preset.textPrimary
        textSecondaryHSV = preset.textSecondary
        customThemeIsDark = preset.isDark
    }
}

struct ThemePresetSection: View {
    let title: String
    let presets: [ThemePreset]
    let selectedPreset: ThemePreset
    let palette: Palette
    let onSelect: (ThemePreset) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
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

    var body: some View {
        Button(action: action) {
            Text(preset.name.lowercased())
                .font(.system(size: 12, weight: .semibold, design: .rounded))
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

    var body: some View {
        HStack {
            Text("THEME")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(palette.textSecondary)
            Spacer()
            Picker("", selection: $isCustomTheme) {
                Text("Presets").tag(false)
                Text("Custom").tag(true)
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .frame(width: 200)
            .onChange(of: isCustomTheme) { _, _ in
                onChange()
            }
        }
    }
}

struct ColorRow: View {
    let title: String
    @Binding var hsv: HSVColor
    let palette: Palette
    @State private var isPickerPresented = false

    var body: some View {
        HStack(spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
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
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(palette.textPrimary)
            Button("Edit") {
                isPickerPresented = true
            }
            .buttonStyle(.bordered)
            .tint(palette.textSecondary)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(title.uppercased()) COLOR")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
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
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(palette.textSecondary)
                Text(hsv.hex)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
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
