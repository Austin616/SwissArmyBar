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
            HStack(alignment: .center, spacing: 24) {
                ZStack {
                    ProgressRing(progress: progress, accent: palette.accent, track: palette.panelStroke)
                        .frame(width: 160, height: 160)
                    VStack(spacing: 6) {
                        Text("TIME REMAINING")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textSecondary)
                        Text(formatTime(timerRemainingSeconds))
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
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

            InspectorSection(title: "Configuration", palette: palette) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("DURATION")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textSecondary)
                        Spacer()
                        Text("\(Int(timerDurationMinutes)) min")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
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
                InspectorDivider(palette: palette)
                HStack {
                    Text("AUTO DND")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                    Spacer()
                    Toggle("", isOn: $autoDNDEnabled)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .tint(palette.accent)
                }
                InspectorDivider(palette: palette)
                HStack {
                    Text("END SOUND")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                    Spacer()
                    Toggle("", isOn: $playEndSound)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .tint(palette.accent)
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
