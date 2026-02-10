import SwiftUI

struct ClipboardView: View {
    @Binding var clipboardItems: [ClipboardItem]
    @Binding var clipboardHistoryLimit: Int
    @Binding var blockedApps: [ClipboardApp]
    let isCompact: Bool
    let palette: Palette

    var body: some View {
        Group {
            if isCompact {
                VStack(alignment: .leading, spacing: 16) {
                    clipboardPrimaryPanel
                    clipboardSidePanel
                }
            } else {
                HStack(alignment: .top, spacing: 20) {
                    clipboardPrimaryPanel
                    clipboardSidePanel
                }
            }
        }
    }

    private var clipboardPrimaryPanel: some View {
        ConfigCard(title: "Recent Clips", palette: palette) {
            HStack {
                Text("Showing last \(clipboardHistoryLimit) items")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
                Spacer()
                Text("\(min(clipboardItems.count, clipboardHistoryLimit)) saved")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.textPrimary)
            }
            ForEach(clipboardItems) { item in
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.text)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(palette.textPrimary)
                                .lineLimit(1)
                            HStack(spacing: 8) {
                                Text(item.source.uppercased())
                                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(palette.textSecondary)
                                Text(item.timestamp)
                                    .font(.system(size: 10, weight: .regular, design: .rounded))
                                    .foregroundStyle(palette.textSecondary)
                            }
                        }
                        Spacer()
                        Button {
                            clipboardItems.removeAll { $0.id == item.id }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(palette.textSecondary)
                                .frame(width: 26, height: 26)
                                .background(
                                    Circle()
                                        .fill(palette.panelFill.opacity(0.7))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    if item.id != clipboardItems.last?.id {
                        Divider()
                            .overlay(palette.divider)
                    }
                }
            }
        }
    }

    private var clipboardSidePanel: some View {
        VStack(spacing: 16) {
            ConfigCard(title: "Capture", palette: palette, minHeight: 140) {
                HStack {
                    Text("Status")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                    Spacer()
                    Text("Active")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                }
                Text("Listening for text snippets only.")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
            }

            ConfigCard(title: "Storage", palette: palette, minHeight: 140) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("History limit")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                        Text("Max saved clips")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
                    }
                    Spacer()
                    NumericInputStepper(
                        value: Binding(
                            get: { Double(clipboardHistoryLimit) },
                            set: { clipboardHistoryLimit = Int($0) }
                        ),
                        range: 3...50,
                        step: 1,
                        suffix: "items",
                        palette: palette
                    )
                }
                ThemedButton(title: "Clear History", style: .secondary, size: .small, palette: palette) {
                    clipboardItems.removeAll()
                }
            }

            ConfigCard(title: "Excluded Apps", palette: palette, minHeight: 160) {
                Text("Don’t capture clipboard from:")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)

                VStack(spacing: 8) {
                    ForEach($blockedApps) { $app in
                        HStack {
                            Text(app.name)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(palette.textPrimary)
                            Spacer()
                            Toggle("", isOn: $app.isBlocked)
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .tint(palette.accent)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: isCompact ? .infinity : 260, alignment: .leading)
    }
}
