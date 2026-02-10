import SwiftUI
import UniformTypeIdentifiers

struct SidebarView: View {
    @Binding var selectedTool: Tool
    @ObservedObject var settings: SidebarSettingsStore
    let isCollapsed: Bool
    let palette: Palette
    @State private var draggingTool: Tool?

    var body: some View {
        VStack(alignment: isCollapsed ? .center : .leading, spacing: 16) {
            if isCollapsed {
                LogoBadge(palette: palette, size: 36)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        LogoBadge(palette: palette, size: 28)
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
                tools: settings.favorites,
                selectedTool: $selectedTool,
                isCollapsed: isCollapsed,
                palette: palette,
                isFavorite: { settings.isFavorite($0) },
                onToggleFavorite: { settings.toggleFavorite($0) },
                draggingTool: $draggingTool
            ) { dragged, target in
                settings.moveFavorite(dragged: dragged, over: target)
            )

            SidebarSection(
                title: "Tools",
                tools: settings.tools,
                selectedTool: $selectedTool,
                isCollapsed: isCollapsed,
                palette: palette,
                isFavorite: { settings.isFavorite($0) },
                onToggleFavorite: { settings.toggleFavorite($0) },
                draggingTool: $draggingTool
            ) { dragged, target in
                settings.moveTool(dragged: dragged, over: target)
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
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.vertical, 16)
        .padding(.horizontal, isCollapsed ? 10 : 16)
        .frame(width: isCollapsed ? 80 : 252)
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

private struct LogoBadge: View {
    let palette: Palette
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(palette.panelFill.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(palette.panelStroke.opacity(0.7), lineWidth: 1)
                )
            Image(systemName: "terminal.fill")
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundStyle(palette.accent)
        }
        .frame(width: size, height: size)
        .shadow(color: palette.glow.opacity(0.4), radius: 4, x: 0, y: 0)
    }
}

private struct SidebarSection: View {
    let title: String
    let tools: [Tool]
    @Binding var selectedTool: Tool
    let isCollapsed: Bool
    let palette: Palette
    let isFavorite: (Tool) -> Bool
    let onToggleFavorite: (Tool) -> Void
    @Binding var draggingTool: Tool?
    let onMove: (Tool, Tool) -> Void

    var body: some View {
        VStack(alignment: isCollapsed ? .center : .leading, spacing: 6) {
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
                    withAnimation(.easeInOut(duration: 0.22)) {
                        selectedTool = tool
                    }
                }
                .contextMenu {
                    Button(isFavorite(tool) ? "Remove from Favorites" : "Add to Favorites") {
                        onToggleFavorite(tool)
                    }
                }
                .onDrag {
                    draggingTool = tool
                    return NSItemProvider(object: tool.rawValue as NSString)
                }
                .onDrop(
                    of: [UTType.text],
                    delegate: SidebarDropDelegate(
                        item: tool,
                        tools: tools,
                        draggingTool: $draggingTool,
                        onMove: onMove
                    )
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: isCollapsed ? .center : .leading)
        .animation(.easeInOut(duration: 0.18), value: tools)
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
            if isCollapsed {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? palette.accent.opacity(0.12) : (isHovering ? palette.panelFill.opacity(0.6) : Color.clear))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isSelected ? palette.accent : Color.clear, lineWidth: 1)
                        )
                    Image(systemName: tool.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? palette.accent : palette.textSecondary)
                }
                .frame(width: 42, height: 42)
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                HStack(spacing: 10) {
                    Rectangle()
                        .fill(isSelected ? palette.accent : Color.clear)
                        .frame(width: 3)
                        .cornerRadius(2)

                    Image(systemName: tool.iconName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isSelected ? palette.accent : palette.textSecondary)
                        .frame(width: 22)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tool.rawValue)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textPrimary)
                        Text(tool.subtitle)
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .foregroundStyle(palette.textSecondary)
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
        }
        .buttonStyle(.plain)
        .help(tool.rawValue)
        .onHover { isHovering in
            self.isHovering = isHovering
        }
    }
}

private struct SidebarDropDelegate: DropDelegate {
    let item: Tool
    let tools: [Tool]
    @Binding var draggingTool: Tool?
    let onMove: (Tool, Tool) -> Void

    func dropEntered(info: DropInfo) {
        guard let dragging = draggingTool,
              dragging != item,
              tools.contains(dragging) else { return }
        onMove(dragging, item)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingTool = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
