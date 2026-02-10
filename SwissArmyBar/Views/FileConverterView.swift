import SwiftUI

struct FileConverterView: View {
    @Binding var detectedInputType: String
    @Binding var selectedOutputType: String
    let supportedOutputTypes: [String]
    let palette: Palette

    private var suggestedOutputType: String {
        switch detectedInputType {
        case "PNG":
            return "JPG"
        case "JPG":
            return "PNG"
        case "HEIC":
            return "JPG"
        case "WEBP":
            return "PNG"
        default:
            return "JPG"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            converterPrimaryPanel
            converterSettingsRow
        }
    }

    private var converterPrimaryPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            InspectorSection(title: "Drop Zone", palette: palette) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(style: StrokeStyle(lineWidth: 1.2, dash: [6, 5]))
                        .foregroundStyle(palette.textSecondary.opacity(0.5))
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(palette.panelFill.opacity(0.5))
                        )

                    VStack(spacing: 8) {
                        Image(systemName: "tray.and.arrow.down.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(palette.accent)
                        Text("Drop a compatible file")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
                        Text("Detects input type automatically")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundStyle(palette.textSecondary)
                    }
                }
                .frame(height: 170)
            }

            InspectorSection(title: "Export", palette: palette) {
                HStack(spacing: 12) {
                    ThemedButton(title: "Download", style: .primary, size: .regular, palette: palette) { }
                    ThemedButton(title: "Reveal in Finder", style: .secondary, size: .regular, palette: palette) { }
                }
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(palette.panelFill.opacity(0.6))
                    .frame(height: 60)
                    .overlay(
                        HStack(spacing: 10) {
                            Image(systemName: "hand.draw")
                                .foregroundStyle(palette.accent)
                            Text("Hold the file thumbnail to drag it out.")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundStyle(palette.textSecondary)
                        }
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var converterSettingsRow: some View {
        HStack(spacing: 16) {
            inputInfoCard
            outputConfigCard
        }
    }

    private var inputInfoCard: some View {
        ConfigCard(title: "Input", palette: palette, minHeight: 150) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Detected type")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                    Text(detectedInputType)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Suggested")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                    Text(suggestedOutputType)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                }
            }
        }
    }

    private var outputConfigCard: some View {
        ConfigCard(title: "Output", palette: palette, minHeight: 150) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Target format")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                    Text(selectedOutputType)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                }
                Spacer()
                ThemedButton(title: "Use Suggested", style: .secondary, size: .small, palette: palette) {
                    selectedOutputType = suggestedOutputType
                }
            }
            HStack(spacing: 8) {
                ForEach(supportedOutputTypes, id: \.self) { type in
                    OutputTypeChip(
                        title: type,
                        isSelected: selectedOutputType == type,
                        isSuggested: suggestedOutputType == type,
                        palette: palette
                    ) {
                        selectedOutputType = type
                    }
                }
            }
        }
    }
}

private struct OutputTypeChip: View {
    let title: String
    let isSelected: Bool
    let isSuggested: Bool
    let palette: Palette
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                if isSuggested {
                    Text("Suggested")
                        .font(.system(size: 8, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(palette.accent.opacity(0.16))
                        )
                }
            }
            .foregroundStyle(isSelected ? palette.textPrimary : palette.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(minHeight: 30)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? palette.accent.opacity(0.18) : palette.panelFill.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(isSelected ? palette.accent : palette.panelStroke, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
