import SwiftUI

struct SidebarView: View {
    @Binding var selectedTool: Tool
    let isCollapsed: Bool
    let palette: Palette

    private let favorites: [Tool] = [.clipboard, .focusTimer]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isCollapsed {
                VStack(alignment: .center, spacing: 6) {
                    Circle()
                        .fill(palette.accent)
                        .frame(width: 8, height: 8)
                        .shadow(color: palette.glow, radius: 4, x: 0, y: 0)
                    Text("SAB")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(palette.accent)
                            .frame(width: 7, height: 7)
                            .shadow(color: palette.glow, radius: 4, x: 0, y: 0)
                        Text("SWISSARMYBAR")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textPrimary)
                    }
                    Text("Utility console v0.1")
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                }
            }

            Divider()
                .overlay(palette.divider.opacity(0.7))

            SidebarSection(
                title: "Favorites",
                tools: favorites,
                selectedTool: $selectedTool,
                isCollapsed: isCollapsed,
                palette: palette
            )

            SidebarSection(
                title: "Tools",
                tools: Tool.allCases.filter { !favorites.contains($0) },
                selectedTool: $selectedTool,
                isCollapsed: isCollapsed,
                palette: palette
            )

            Spacer(minLength: 12)

            if !isCollapsed {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Status")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                    Text("All systems nominal.")
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(palette.textSecondary)
                }
            }
        }
        .padding(18)
        .frame(width: isCollapsed ? 72 : 250)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.panelFill.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(palette.panelStroke.opacity(0.7), lineWidth: 1)
                )
        )
    }
}

private struct SidebarSection: View {
    let title: String
    let tools: [Tool]
    @Binding var selectedTool: Tool
    let isCollapsed: Bool
    let palette: Palette

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !isCollapsed {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(palette.textSecondary)
                    .padding(.leading, 6)
            }
            ForEach(tools) { tool in
                SidebarRow(
                    tool: tool,
                    isSelected: selectedTool == tool,
                    isCollapsed: isCollapsed,
                    palette: palette
                ) {
                    selectedTool = tool
                }
            }
        }
    }
}

private struct SidebarRow: View {
    let tool: Tool
    let isSelected: Bool
    let isCollapsed: Bool
    let palette: Palette
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Rectangle()
                    .fill(isSelected ? palette.accent : Color.clear)
                    .frame(width: 3)
                    .cornerRadius(2)

                Image(systemName: tool.iconName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? palette.accent : palette.textSecondary)
                    .frame(width: 22)

                if !isCollapsed {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tool.rawValue)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textPrimary)
                        Text(tool.subtitle)
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .foregroundStyle(palette.textSecondary)
                    }
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 6)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? palette.accent.opacity(0.10) : (isHovering ? palette.panelFill.opacity(0.6) : Color.clear))
            )
        }
        .buttonStyle(.plain)
        .help(tool.rawValue)
        .onHover { isHovering in
            self.isHovering = isHovering
        }
    }
}
