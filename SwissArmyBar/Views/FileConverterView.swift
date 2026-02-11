import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct FileConverterView: View {
    @Binding var detectedInputType: String
    @Binding var selectedOutputType: String
    let supportedOutputTypes: [String]
    let isCompact: Bool
    let palette: Palette
    @State private var droppedURL: URL?
    @State private var outputURL: URL?
    @State private var conversionStatus: String?
    @State private var isDropTargeted = false
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }
    @State private var isHoveringExport = false

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
                        .foregroundStyle(isDropTargeted ? palette.accent : palette.textSecondary.opacity(0.5))
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(palette.panelFill.opacity(0.5))
                        )

                    VStack(spacing: 8) {
                        Image(systemName: "tray.and.arrow.down.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(palette.accent)
                        Text(droppedURL?.lastPathComponent ?? "Drop a compatible file")
                            .font(typography.font(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
                        Text(droppedURL == nil ? "Detects input type automatically" : "Ready to convert")
                            .font(typography.font(size: 11, weight: .regular, design: .rounded))
                            .foregroundStyle(palette.textSecondary)
                        ThemedButton(title: "Choose File", style: .secondary, size: .small, palette: palette) {
                            openFilePicker()
                        }
                    }
                }
                .frame(height: 170)
                .onDrop(of: [UTType.fileURL], isTargeted: $isDropTargeted) { providers in
                    guard let provider = providers.first else { return false }
                    provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                        DispatchQueue.main.async {
                            guard let data = item as? Data,
                                  let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                            handlePickedURL(url)
                        }
                    }
                    return true
                }
            }

            InspectorSection(title: "Export", palette: palette) {
                HStack(spacing: 12) {
                    ThemedButton(title: "Export", style: .primary, size: .regular, palette: palette) {
                        convertFile()
                    }
                    if outputURL != nil {
                        ThemedButton(title: "Download", style: .secondary, size: .regular, palette: palette) {
                            saveExport()
                        }
                    }
                }
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isHoveringExport ? palette.panelFill.opacity(0.7) : palette.panelFill.opacity(0.6))
                    .frame(height: 60)
                    .overlay(
                        Group {
                            if let outputURL {
                                HStack(spacing: 10) {
                                    Image(nsImage: NSWorkspace.shared.icon(forFile: outputURL.path))
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .cornerRadius(4)
                                    Text("Drag to save")
                                        .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundStyle(palette.textPrimary)
                                    Spacer()
                                    Text(outputURL.lastPathComponent)
                                        .font(typography.font(size: 11, weight: .regular, design: .rounded))
                                        .foregroundStyle(palette.textSecondary)
                                }
                                .padding(.horizontal, 12)
                                .onDrag {
                                    NSItemProvider(contentsOf: outputURL) ?? NSItemProvider()
                                }
                            } else {
                                HStack(spacing: 10) {
                                    Image(systemName: "hand.draw")
                                        .foregroundStyle(palette.accent)
                                    Text(conversionStatus ?? "Export to enable download or drag.")
                                        .font(typography.font(size: 12, weight: .regular, design: .rounded))
                                        .foregroundStyle(palette.textSecondary)
                                }
                            }
                        }
                    )
                    .onHover { isHoveringExport = $0 }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var converterSettingsRow: some View {
        Group {
            if isCompact {
                VStack(spacing: 16) {
                    inputInfoCard
                    outputConfigCard
                }
            } else {
                HStack(spacing: 16) {
                    inputInfoCard
                    outputConfigCard
                }
            }
        }
    }

    private var inputInfoCard: some View {
        ConfigCard(title: "Input", palette: palette, minHeight: 150) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Detected type")
                        .font(typography.font(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                    Text(detectedInputType)
                        .font(typography.font(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Suggested")
                        .font(typography.font(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                    Text(suggestedOutputType)
                        .font(typography.font(size: 14, weight: .semibold, design: .rounded))
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
                        .font(typography.font(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                    Text(selectedOutputType)
                        .font(typography.font(size: 18, weight: .semibold, design: .rounded))
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

    private func convertFile() {
        guard let inputURL = droppedURL else {
            conversionStatus = "Drop a file first."
            return
        }
        do {
            outputURL = try ImageConversionService.convert(inputURL: inputURL, outputType: selectedOutputType)
            conversionStatus = "Converted to \(selectedOutputType.uppercased())."
        } catch ImageConversionError.unsupported {
            conversionStatus = "Format not supported yet."
        } catch {
            conversionStatus = "Conversion failed."
        }
    }

    private func saveExport() {
        guard let outputURL else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = outputURL.lastPathComponent
        panel.begin { response in
            guard response == .OK, let destination = panel.url else { return }
            do {
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.copyItem(at: outputURL, to: destination)
                conversionStatus = "Saved to \(destination.lastPathComponent)."
            } catch {
                conversionStatus = "Save failed."
            }
        }
    }

    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            handlePickedURL(url)
        }
    }

    private func handlePickedURL(_ url: URL) {
        droppedURL = url
        detectedInputType = url.pathExtension.uppercased()
        if supportedOutputTypes.contains(suggestedOutputType) {
            selectedOutputType = suggestedOutputType
        }
        conversionStatus = nil
        outputURL = nil
    }

    
}

private struct OutputTypeChip: View {
    let title: String
    let isSelected: Bool
    let isSuggested: Bool
    let palette: Palette
    let action: () -> Void
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(typography.font(size: 11, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                if isSuggested {
                    Text("Suggested")
                        .font(typography.font(size: 8, weight: .semibold, design: .rounded))
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
                    .fill(isSelected ? palette.accent.opacity(0.18) : (isHovering ? palette.panelFill.opacity(0.75) : palette.panelFill.opacity(0.6)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(isSelected ? palette.accent : palette.panelStroke, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}
