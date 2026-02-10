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
        VStack(alignment: .leading, spacing: 24) {
            VStack(spacing: 18) {
                ZStack {
                    ProgressRing(progress: progress, accent: palette.accent, track: palette.panelStroke)
                        .frame(width: 220, height: 220)
                    VStack(spacing: 6) {
                        Text("TIME REMAINING")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textSecondary)
                        Text(formatTime(timerRemainingSeconds))
                            .font(.system(size: 40, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
                    }
                }

                HStack(spacing: 12) {
                    TimerActionButton(title: "Start", style: .primary, palette: palette) { }
                    TimerActionButton(title: "Pause", style: .secondary, palette: palette) { }
                    TimerActionButton(title: "Reset", style: .ghost, palette: palette) {
                        timerRemainingSeconds = Int(timerDurationMinutes * 60)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Divider()
                .overlay(palette.divider.opacity(0.7))

            HStack(alignment: .center, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Duration")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                    NumericInputStepper(
                        value: $timerDurationMinutes,
                        range: 5...90,
                        step: 5,
                        suffix: "min",
                        palette: palette
                    )
                    .onChange(of: timerDurationMinutes) { _, newValue in
                        timerRemainingSeconds = Int(newValue * 60)
                    }
                    HStack(spacing: 8) {
                        DurationChip(title: "15m", isSelected: Int(timerDurationMinutes) == 15, palette: palette) {
                            timerDurationMinutes = 15
                            timerRemainingSeconds = 15 * 60
                        }
                        DurationChip(title: "25m", isSelected: Int(timerDurationMinutes) == 25, palette: palette) {
                            timerDurationMinutes = 25
                            timerRemainingSeconds = 25 * 60
                        }
                        DurationChip(title: "50m", isSelected: Int(timerDurationMinutes) == 50, palette: palette) {
                            timerDurationMinutes = 50
                            timerRemainingSeconds = 50 * 60
                        }
                    }
                }

                Spacer(minLength: 0)

                HStack(spacing: 16) {
                    InlineSwitch(title: "Auto DND", isOn: $autoDNDEnabled, palette: palette)
                    InlineSwitch(title: "End Sound", isOn: $playEndSound, palette: palette)
                }
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = max(0, seconds) / 60
        let remaining = max(0, seconds) % 60
        return String(format: "%02d:%02d", minutes, remaining)
    }
}

private enum TimerButtonStyle {
    case primary
    case secondary
    case ghost
}

private struct TimerActionButton: View {
    let title: String
    let style: TimerButtonStyle
    let palette: Palette
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(foregroundColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(backgroundShape)
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return Color.white
        case .secondary:
            return palette.textPrimary
        case .ghost:
            return palette.textSecondary
        }
    }

    @ViewBuilder
    private var backgroundShape: some View {
        switch style {
        case .primary:
            Capsule().fill(palette.accent)
        case .secondary:
            Capsule()
                .fill(palette.panelFill.opacity(0.5))
                .overlay(
                    Capsule().stroke(palette.panelStroke, lineWidth: 1)
                )
        case .ghost:
            Capsule()
                .fill(Color.clear)
                .overlay(
                    Capsule().stroke(palette.panelStroke.opacity(0.6), lineWidth: 1)
                )
        }
    }
}

private struct DurationChip: View {
    let title: String
    let isSelected: Bool
    let palette: Palette
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
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

private struct InlineSwitch: View {
    let title: String
    @Binding var isOn: Bool
    let palette: Palette

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.textPrimary)
        }
        .toggleStyle(.switch)
        .tint(palette.accent)
    }
}
