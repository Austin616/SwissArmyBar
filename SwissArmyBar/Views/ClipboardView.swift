import SwiftUI

struct ClipboardView: View {
    @Binding var clipboardItems: [ClipboardItem]
    @Binding var clipboardHistoryLimit: Int
    let palette: Palette

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Saved",
                    value: "\(min(clipboardItems.count, clipboardHistoryLimit)) / \(clipboardHistoryLimit)",
                    subtitle: "Text clips",
                    palette: palette
                )
                StatCard(
                    title: "Listener",
                    value: "Active",
                    subtitle: "Text only",
                    palette: palette
                )
            }

            InspectorSection(title: "Storage", palette: palette) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HISTORY LIMIT")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textSecondary)
                        Text("\(clipboardHistoryLimit) items")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
                    }
                    Spacer()
                    Stepper("", value: $clipboardHistoryLimit, in: 3...50)
                        .labelsHidden()
                }
                InspectorDivider(palette: palette)
                HStack {
                    Text("CLEAR ALL")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                    Spacer()
                    Button("Clear History") {
                        clipboardItems.removeAll()
                    }
                    .buttonStyle(.bordered)
                    .tint(palette.textSecondary)
                }
            }

            InspectorSection(title: "Recent Clips", palette: palette) {
                ForEach(clipboardItems) { item in
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
                        InspectorDivider(palette: palette)
                    }
                }
            }
        }
    }
}
