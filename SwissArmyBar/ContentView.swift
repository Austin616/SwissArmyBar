//
//  ContentView.swift
//  SwissArmyBar
//
//  Created by Austin Tran on 2/10/26.
//

import SwiftUI

struct ContentView: View {
    enum Tool: String, CaseIterable, Identifiable {
        case clipboard = "Clipboard"
        case focusTimer = "Focus Timer"
        case fileConverter = "File Converter"

        var id: String { rawValue }

        var iconName: String {
            switch self {
            case .clipboard:
                return "doc.on.clipboard"
            case .focusTimer:
                return "timer"
            case .fileConverter:
                return "square.and.arrow.down"
            }
        }

        var subtitle: String {
            switch self {
            case .clipboard:
                return "Capture and reuse recent text"
            case .focusTimer:
                return "Stay on task with a simple timer"
            case .fileConverter:
                return "Drop .png files to convert"
            }
        }
    }

    struct Palette {
        let backgroundTop: Color
        let backgroundBottom: Color
        let panelFill: Color
        let panelStroke: Color
        let cardFill: Color
        let textPrimary: Color
        let textSecondary: Color
        let accent: Color
        let divider: Color
        let successFill: Color

        init(isDark: Bool) {
            if isDark {
                backgroundTop = Color(red: 0.09, green: 0.10, blue: 0.14)
                backgroundBottom = Color(red: 0.12, green: 0.14, blue: 0.20)
                panelFill = Color(red: 0.13, green: 0.15, blue: 0.21)
                panelStroke = Color.white.opacity(0.08)
                cardFill = Color(red: 0.17, green: 0.19, blue: 0.25)
                textPrimary = Color.white.opacity(0.92)
                textSecondary = Color.white.opacity(0.62)
                accent = Color(red: 0.38, green: 0.69, blue: 0.98)
                divider = Color.white.opacity(0.08)
                successFill = Color(red: 0.18, green: 0.28, blue: 0.24)
            } else {
                backgroundTop = Color(red: 0.97, green: 0.97, blue: 0.98)
                backgroundBottom = Color(red: 0.92, green: 0.94, blue: 0.97)
                panelFill = Color.white.opacity(0.85)
                panelStroke = Color.black.opacity(0.06)
                cardFill = Color.white
                textPrimary = Color.black.opacity(0.86)
                textSecondary = Color.black.opacity(0.50)
                accent = Color(red: 0.12, green: 0.52, blue: 0.90)
                divider = Color.black.opacity(0.06)
                successFill = Color(red: 0.88, green: 0.96, blue: 0.92)
            }
        }
    }

    @State private var selectedTool: Tool = .clipboard
    @State private var isDarkModeEnabled = false

    private let sampleSnippets = [
        "Client brief: refresh onboarding flow and email copy.",
        "https://design.example.com/brand/kit",
        "Color palette: #0B132B, #1C2541, #5BC0BE",
        "TODO: ship MVP build by Friday.",
        "Meeting notes: keep converter output in place."
    ]

    var body: some View {
        let palette = Palette(isDark: isDarkModeEnabled)

        ZStack {
            LinearGradient(
                colors: [palette.backgroundTop, palette.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            HStack(spacing: 20) {
                sidebar(palette: palette)
                detailArea(palette: palette)
            }
            .padding(24)
        }
        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
        .frame(minWidth: 920, minHeight: 600)
    }

    private func sidebar(palette: Palette) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Swiss Army Bar")
                    .font(.custom("Avenir Next", size: 24).weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                Text("All-in-one utility hub")
                    .font(.custom("Avenir Next", size: 14))
                    .foregroundStyle(palette.textSecondary)
            }

            Divider()
                .overlay(palette.divider)

            VStack(spacing: 10) {
                ForEach(Tool.allCases) { tool in
                    Button {
                        selectedTool = tool
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: tool.iconName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(selectedTool == tool ? palette.accent : palette.textSecondary)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(tool.rawValue)
                                    .font(.custom("Avenir Next", size: 15).weight(.semibold))
                                    .foregroundStyle(palette.textPrimary)
                                Text(tool.subtitle)
                                    .font(.custom("Avenir Next", size: 12))
                                    .foregroundStyle(palette.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .contentShape(Rectangle())
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedTool == tool ? palette.accent.opacity(0.14) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                Text("Settings")
                    .font(.custom("Avenir Next", size: 13).weight(.semibold))
                    .foregroundStyle(palette.textSecondary)

                Toggle(isOn: $isDarkModeEnabled) {
                    Text("Dark Mode")
                        .font(.custom("Avenir Next", size: 14))
                        .foregroundStyle(palette.textPrimary)
                }
                .toggleStyle(.switch)
                .tint(palette.accent)
            }
        }
        .padding(20)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(palette.panelFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
        )
    }

    private func detailArea(palette: Palette) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text(selectedTool.rawValue)
                    .font(.custom("Avenir Next", size: 28).weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                Text(selectedTool.subtitle)
                    .font(.custom("Avenir Next", size: 14))
                    .foregroundStyle(palette.textSecondary)
            }

            Divider()
                .overlay(palette.divider)

            switch selectedTool {
            case .clipboard:
                clipboardView(palette: palette)
            case .focusTimer:
                focusTimerView(palette: palette)
            case .fileConverter:
                fileConverterView(palette: palette)
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(palette.panelFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
        )
    }

    private func clipboardView(palette: Palette) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Last 5 Text Snippets")
                .font(.custom("Avenir Next", size: 16).weight(.semibold))
                .foregroundStyle(palette.textPrimary)

            VStack(spacing: 12) {
                ForEach(sampleSnippets, id: \.self) { snippet in
                    Button {
                        // UI only for MVP
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.on.doc")
                                .foregroundStyle(palette.accent)
                            Text(snippet)
                                .font(.custom("Avenir Next", size: 14))
                                .foregroundStyle(palette.textPrimary)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(12)
                        .contentShape(Rectangle())
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(palette.cardFill)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(palette.panelStroke, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("Click a snippet to re-copy it to your clipboard.")
                .font(.custom("Avenir Next", size: 13))
                .foregroundStyle(palette.textSecondary)
        }
    }

    private func focusTimerView(palette: Palette) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Time Remaining")
                    .font(.custom("Avenir Next", size: 16).weight(.semibold))
                    .foregroundStyle(palette.textSecondary)
                Text("25:00")
                    .font(.custom("Avenir Next", size: 56).weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
            }

            HStack(spacing: 12) {
                Button("Start") { }
                    .buttonStyle(.borderedProminent)
                    .tint(palette.accent)
                Button("Stop") { }
                    .buttonStyle(.bordered)
                Button("Reset") { }
                    .buttonStyle(.bordered)
            }

            Text("Static 25-minute countdown for the MVP.")
                .font(.custom("Avenir Next", size: 13))
                .foregroundStyle(palette.textSecondary)
        }
    }

    private func fileConverterView(palette: Palette) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Drop Zone")
                .font(.custom("Avenir Next", size: 16).weight(.semibold))
                .foregroundStyle(palette.textPrimary)

            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
                    .foregroundStyle(palette.textSecondary.opacity(0.5))
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(palette.cardFill)
                    )

                VStack(spacing: 10) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(palette.accent)
                    Text("Drop .png files here to convert to .jpg")
                        .font(.custom("Avenir Next", size: 14))
                        .foregroundStyle(palette.textSecondary)
                }
            }
            .frame(height: 200)

            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.green)
                Text("Last conversion: Success")
                    .font(.custom("Avenir Next", size: 13).weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(palette.successFill)
            )

            Text("Converts .png to .jpg and keeps the original file intact.")
                .font(.custom("Avenir Next", size: 13))
                .foregroundStyle(palette.textSecondary)
        }
    }
}

#Preview {
    ContentView()
}
