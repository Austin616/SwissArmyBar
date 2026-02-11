import SwiftUI
import Combine

struct FocusTimerView: View {
    @ObservedObject var timer: TimerStore
    let palette: Palette
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    private var unitLabel: String { appSettings.timeUnitStyle.label }
    private var chipLabel: String { appSettings.timeUnitStyle.label }

    private var progress: Double {
        timer.durationMinutes > 0
            ? Double(timer.remainingSeconds) / Double(timer.durationMinutes * 60)
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
                            .font(typography.font(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textSecondary)
                        Text(formatTime(timer.remainingSeconds))
                            .font(typography.font(size: 40, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
                    }
                }

                HStack(spacing: 12) {
                    TimerActionButton(
                        title: timer.isRunning ? "Pause" : "Start",
                        style: .primary,
                        palette: palette
                    ) {
                        if timer.isRunning {
                            timer.pause()
                        } else {
                            timer.start()
                        }
                    }
                    TimerActionButton(title: "Reset", style: .secondary, palette: palette) {
                        timer.reset()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Divider()
                .overlay(palette.divider.opacity(0.7))

            HStack(alignment: .center, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Duration")
                        .font(typography.font(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                    NumericInputStepper(
                        value: $timer.durationMinutes,
                        range: 1...90,
                        step: 1,
                        suffix: unitLabel,
                        palette: palette
                    )
                    HStack(spacing: 8) {
                        DurationChip(title: "15 \(chipLabel)", isSelected: Int(timer.durationMinutes) == 15, palette: palette) {
                            timer.durationMinutes = 15
                        }
                        DurationChip(title: "25 \(chipLabel)", isSelected: Int(timer.durationMinutes) == 25, palette: palette) {
                            timer.durationMinutes = 25
                        }
                        DurationChip(title: "50 \(chipLabel)", isSelected: Int(timer.durationMinutes) == 50, palette: palette) {
                            timer.durationMinutes = 50
                        }
                    }
                }

                Spacer(minLength: 0)

                HStack(spacing: 16) {
                    InlineSwitch(title: "Auto DND", isOn: $timer.autoDNDEnabled, palette: palette)
                    InlineSwitch(title: "End Sound", isOn: $timer.playEndSound, palette: palette)
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
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(typography.font(size: 13, weight: .semibold, design: .rounded))
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

private struct InlineSwitch: View {
    let title: String
    @Binding var isOn: Bool
    let palette: Palette
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.textPrimary)
        }
        .toggleStyle(.switch)
        .tint(palette.accent)
    }
}
