import SwiftUI

struct FileConverterView: View {
    @Binding var detectedInputType: String
    @Binding var selectedOutputType: String
    @Binding var useSuggestedOutput: Bool
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
        VStack(alignment: .leading, spacing: 18) {
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
                .frame(height: 150)
            }

            InspectorSection(title: "Detected", palette: palette) {
                HStack {
                    Text("INPUT TYPE")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                    Spacer()
                    Text(detectedInputType)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                }
                InspectorDivider(palette: palette)
                HStack {
                    Text("SUGGESTED")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                    Spacer()
                    Text(suggestedOutputType)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                }
                InspectorDivider(palette: palette)
                HStack {
                    Text("OUTPUT TYPE")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                    Spacer()
                    Picker("", selection: $selectedOutputType) {
                        ForEach(supportedOutputTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(width: 220)
                    .disabled(useSuggestedOutput)
                }
                InspectorDivider(palette: palette)
                HStack {
                    Text("USE SUGGESTED")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                    Spacer()
                    Toggle("", isOn: $useSuggestedOutput)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .tint(palette.accent)
                        .onChange(of: useSuggestedOutput) { _, newValue in
                            if newValue {
                                selectedOutputType = suggestedOutputType
                            }
                        }
                }
            }

            InspectorSection(title: "Export", palette: palette) {
                HStack(spacing: 12) {
                    Button("Download") { }
                        .buttonStyle(.borderedProminent)
                        .tint(palette.accent)
                    Button("Reveal in Finder") { }
                        .buttonStyle(.bordered)
                        .tint(palette.textSecondary)
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
        .onChange(of: detectedInputType) { _, _ in
            if useSuggestedOutput {
                selectedOutputType = suggestedOutputType
            }
        }
    }
}
