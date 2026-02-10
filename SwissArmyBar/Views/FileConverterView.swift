import SwiftUI
import AppKit
import UniformTypeIdentifiers
import ImageIO

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
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
                        Text(droppedURL == nil ? "Detects input type automatically" : "Ready to convert")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
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
                    ThemedButton(title: "Convert", style: .primary, size: .regular, palette: palette) {
                        convertFile()
                    }
                    ThemedButton(title: "Reveal in Finder", style: .secondary, size: .regular, palette: palette) {
                        if let outputURL {
                            NSWorkspace.shared.activateFileViewerSelecting([outputURL])
                        }
                    }
                }
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(palette.panelFill.opacity(0.6))
                    .frame(height: 60)
                    .overlay(
                        HStack(spacing: 10) {
                            Image(systemName: "hand.draw")
                                .foregroundStyle(palette.accent)
                            Text(conversionStatus ?? "Drop a file to enable conversion.")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundStyle(palette.textSecondary)
                        }
                    )
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

    private func convertFile() {
        guard let inputURL = droppedURL else {
            conversionStatus = "Drop a file first."
            return
        }
        guard let image = NSImage(contentsOf: inputURL) else {
            conversionStatus = "Unsupported file."
            return
        }

        let outputExtension = selectedOutputType.lowercased()
        let outputName = inputURL.deletingPathExtension().lastPathComponent + "-converted.\(outputExtension)"
        let output = FileManager.default.temporaryDirectory.appendingPathComponent(outputName)

        let success: Bool
        switch selectedOutputType.uppercased() {
        case "JPG", "JPEG":
            success = write(image: image, to: output, type: .jpeg, compression: 0.9)
        case "PNG":
            success = write(image: image, to: output, type: .png, compression: 1.0)
        case "HEIC":
            success = writeHEIC(image: image, to: output)
        default:
            conversionStatus = "Format not supported yet."
            return
        }

        if success {
            outputURL = output
            conversionStatus = "Converted to \(selectedOutputType.uppercased())."
        } else {
            conversionStatus = "Conversion failed."
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

    private func write(image: NSImage, to url: URL, type: NSBitmapImageRep.FileType, compression: CGFloat) -> Bool {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let data = rep.representation(using: type, properties: [.compressionFactor: compression]) else {
            return false
        }
        do {
            try data.write(to: url)
            return true
        } catch {
            return false
        }
    }

    private func writeHEIC(image: NSImage, to url: URL) -> Bool {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return false
        }
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.heic.identifier as CFString, 1, nil) else {
            return false
        }
        let options: CFDictionary = [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, options)
        return CGImageDestinationFinalize(destination)
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
