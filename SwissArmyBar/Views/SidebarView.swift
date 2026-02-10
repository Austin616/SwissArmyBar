import SwiftUI

struct SidebarView: View {
    @Binding var selectedTool: Tool
    let palette: Palette

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(palette.accent)
                        .frame(width: 8, height: 8)
                        .shadow(color: palette.glow, radius: 6, x: 0, y: 0)
                    Text("SWISSARMYBAR")
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textPrimary)
                }
                Text("Utility console v0.1")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
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
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(selectedTool == tool ? palette.accent : palette.textSecondary)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(tool.rawValue)
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(palette.textPrimary)
                                Text(tool.subtitle)
                                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                                    .foregroundStyle(palette.textSecondary)
                            }
                            Spacer()
                            if selectedTool == tool {
                                Text("ACTIVE")
                                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(palette.accent)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(palette.accent.opacity(0.12))
                                    )
                            }
                        }
                        .padding(10)
                        .contentShape(Rectangle())
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(selectedTool == tool ? palette.accent.opacity(0.10) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                Text("Status")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(palette.textSecondary)
                Text("All systems nominal.")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(palette.textSecondary)
            }
        }
        .padding(20)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.panelFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(palette.panelStroke, lineWidth: 1)
                )
        )
    }
}
