import SwiftUI

struct InfoSheetView: View {
    let palette: Palette
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [palette.backgroundTop, palette.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundStyle(palette.accent)
                        Text("How to Use Swiss Army Bar")
                            .font(typography.font(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
                    }
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(palette.textSecondary)
                            .frame(width: 28, height: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(palette.cardFill)
                            )
                    }
                    .buttonStyle(.plain)
                }

                HelpRow(
                    title: "Toggle Sidebar",
                    detail: "Use the shortcut to show or hide the sidebar.",
                    palette: palette,
                    trailing: Keycap(text: "⌘S", palette: palette)
                )

                VStack(alignment: .leading, spacing: 10) {
                    HelpRow(
                        title: "Clipboard",
                        detail: "Recent clips appear in the main column. Use the side panel to adjust history.",
                        palette: palette
                    )
                    HelpRow(
                        title: "Focus Timer",
                        detail: "Use Start/Stop/Reset and adjust duration in the side panel.",
                        palette: palette
                    )
                    HelpRow(
                        title: "File Converter",
                        detail: "Drop a compatible file, pick the output format, then export.",
                        palette: palette
                    )
                    HelpRow(
                        title: "Themes",
                        detail: "Choose a preset or switch to Custom to edit colors.",
                        palette: palette
                    )
                }

                Spacer()
            }
            .padding(20)
            .frame(minWidth: 440, minHeight: 340)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(palette.panelFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(palette.panelStroke, lineWidth: 1)
                    )
            )
            .padding(16)
        }
    }
}

private struct HelpRow: View {
    let title: String
    let detail: String
    let palette: Palette
    var trailing: AnyView? = nil
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    init<Content: View>(title: String, detail: String, palette: Palette, trailing: Content) {
        self.title = title
        self.detail = detail
        self.palette = palette
        self.trailing = AnyView(trailing)
    }

    init(title: String, detail: String, palette: Palette) {
        self.title = title
        self.detail = detail
        self.palette = palette
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(typography.font(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.textPrimary)
                Text(detail)
                    .font(typography.font(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
            }
            Spacer()
            if let trailing {
                trailing
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
        )
    }
}

private struct Keycap: View {
    let text: String
    let palette: Palette
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        Text(text)
            .font(typography.font(size: 11, weight: .semibold, design: .monospaced))
            .foregroundStyle(palette.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(palette.panelFill.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(palette.panelStroke, lineWidth: 1)
                    )
            )
    }
}
