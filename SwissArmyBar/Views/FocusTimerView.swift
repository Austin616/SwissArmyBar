import SwiftUI

struct FocusTimerView: View {
    @Binding var timerDurationMinutes: Double
    @Binding var timerRemainingSeconds: Int
    @Binding var autoDNDEnabled: Bool
    @Binding var playEndSound: Bool
    let palette: Palette

    private var progress: Double {
        timerDurationMinutes > 0
            ? Double(timerRemainingSeconds) / (timerDurationMinutes * 60)
            : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                ZStack {
                    ProgressRing(progress: progress, accent: palette.accent, track: palette.panelStroke)
                        .frame(width: 190, height: 190)
                    VStack(spacing: 6) {
                        Text("TIME REMAINING")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textSecondary)
                        Text(formatTime(timerRemainingSeconds))
                            .font(.system(size: 34, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
                    }
                }
                Spacer()
            }

            HStack(spacing: 12) {
                ThemedButton(title: "Start", style: .primary, size: .regular, palette: palette) { }
                ThemedButton(title: "Pause", style: .secondary, size: .regular, palette: palette) { }
                ThemedButton(title: "Reset", style: .secondary, size: .regular, palette: palette) {
                    timerRemainingSeconds = Int(timerDurationMinutes * 60)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            settingsBar
        }
    }

    private var settingsBar: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Duration")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
                HStack {
                    Text("\(Int(timerDurationMinutes)) min")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                    Spacer()
                }
                Slider(value: $timerDurationMinutes, in: 5...90, step: 5)
                    .tint(palette.accent)
                    .onChange(of: timerDurationMinutes) { _, newValue in
                        timerRemainingSeconds = Int(newValue * 60)
                    }
            HStack(spacing: 8) {
                QuickDurationButton(title: "15", value: 15, palette: palette) {
                    timerDurationMinutes = 15
                    timerRemainingSeconds = 15 * 60
                }
                QuickDurationButton(title: "25", value: 25, palette: palette) {
                    timerDurationMinutes = 25
                    timerRemainingSeconds = 25 * 60
                }
                QuickDurationButton(title: "50", value: 50, palette: palette) {
                    timerDurationMinutes = 50
                    timerRemainingSeconds = 50 * 60
                }
            }
            }

            Divider()
                .frame(height: 72)
                .overlay(palette.divider)

            VStack(alignment: .leading, spacing: 12) {
                ToggleRow(
                    title: "Auto DND",
                    subtitle: "Enable Do Not Disturb on start",
                    isOn: $autoDNDEnabled,
                    palette: palette
                )
                ToggleRow(
                    title: "End Sound",
                    subtitle: "Play a sound when complete",
                    isOn: $playEndSound,
                    palette: palette
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
        )
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = max(0, seconds) / 60
        let remaining = max(0, seconds) % 60
        return String(format: "%02d:%02d", minutes, remaining)
    }
}

private struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let palette: Palette

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(palette.accent)
        }
    }
}

struct QuickDurationButton: View {
    let title: String
    let value: Double
    let palette: Palette
    let action: () -> Void

    var body: some View {
        ThemedButton(title: "\(title)m", style: .secondary, size: .small, palette: palette, action: action)
    }
}
