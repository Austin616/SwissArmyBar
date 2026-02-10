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
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 20) {
                timerPrimaryPanel
                timerSettingsPanel
            }
        }
    }

    private var timerPrimaryPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 24) {
                ZStack {
                    ProgressRing(progress: progress, accent: palette.accent, track: palette.panelStroke)
                        .frame(width: 150, height: 150)
                    VStack(spacing: 6) {
                        Text("TIME REMAINING")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textSecondary)
                        Text(formatTime(timerRemainingSeconds))
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Focus Timer")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                    Text("Configurable session length with optional Auto‑DND.")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)

                    HStack(spacing: 10) {
                        Button("Start") { }
                            .buttonStyle(.borderedProminent)
                            .tint(palette.accent)
                        Button("Stop") { }
                            .buttonStyle(.bordered)
                            .tint(palette.textSecondary)
                        Button("Reset") {
                            timerRemainingSeconds = Int(timerDurationMinutes * 60)
                        }
                        .buttonStyle(.bordered)
                        .tint(palette.textSecondary)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(palette.cardFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(palette.panelStroke, lineWidth: 1)
                    )
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var timerSettingsPanel: some View {
        VStack(spacing: 16) {
            configDurationCard
            configAutomationCard
        }
        .frame(width: 260)
    }

    private var configDurationCard: some View {
        ConfigCard(title: "Duration", palette: palette, minHeight: 180) {
            HStack {
                Text("\(Int(timerDurationMinutes)) min")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.textPrimary)
                Spacer()
                Text("Session length")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
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
    }

    private var configAutomationCard: some View {
        ConfigCard(title: "Automation", palette: palette, minHeight: 180) {
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
        Button("\(title)m", action: action)
            .buttonStyle(.bordered)
            .tint(palette.textSecondary)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
    }
}
