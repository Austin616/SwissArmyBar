import SwiftUI
import AppKit

struct ClipboardView: View {
    @ObservedObject var monitor: ClipboardMonitor
    @ObservedObject var settings: ClipboardSettingsStore
    let installedApps: [InstalledApp]
    let isCompact: Bool
    let palette: Palette
    @State private var isExcludedAppsPresented = false
    @State private var toastMessage: String? = nil
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

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
        ZStack(alignment: .topTrailing) {
            ConfigCard(title: "Recent Clips", palette: palette) {
                HStack {
                    Text("Showing last \(settings.historyLimit) items")
                        .font(typography.font(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                    Spacer()
                    ThemedButton(title: "Clear All", style: .ghost, size: .small, palette: palette) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            monitor.clear()
                        }
                    }
                    Text("\(min(monitor.items.count, settings.historyLimit)) saved")
                        .font(typography.font(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                }
            let visibleItems = Array(monitor.items.prefix(settings.historyLimit))
            ForEach(visibleItems) { item in
                ClipboardItemRow(
                    item: item,
                    palette: palette,
                    typography: typography,
                    showDivider: item.id != visibleItems.last?.id,
                    onSelect: { copyToClipboard(item) },
                    onDelete: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            monitor.remove(item)
                        }
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: monitor.items)

            if let toastMessage {
                Text(toastMessage)
                    .font(typography.font(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(palette.panelFill.opacity(0.9))
                            .overlay(
                                Capsule().stroke(palette.panelStroke, lineWidth: 1)
                            )
                    )
                    .padding(.top, 6)
                    .padding(.trailing, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var clipboardSidePanel: some View {
        VStack(spacing: 16) {
            ConfigCard(title: "Capture", palette: palette, minHeight: 140) {
                HStack {
                    Text("Status")
                        .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                    Spacer()
                    Text("Active")
                        .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                }
                Text("Listening for text and images.")
                    .font(typography.font(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
            }

            ConfigCard(title: "Storage", palette: palette, minHeight: 140) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("History limit")
                        .font(typography.font(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                        Text("Max saved clips")
                            .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
                    }
                    Spacer()
                    NumericInputStepper(
                        value: $settings.historyLimit,
                        range: 3...50,
                        step: 1,
                        suffix: "items",
                        palette: palette
                    )
                }
                ThemedButton(title: "Clear History", style: .secondary, size: .small, palette: palette) {
                    monitor.clear()
                }
            }

            ConfigCard(title: "Excluded Apps", palette: palette, minHeight: 140) {
                Text("Exclude clipboard capture from specific apps.")
                    .font(typography.font(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
                HStack {
                    Text("\(settings.blockedBundleIds.count) apps blocked")
                        .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                    Spacer()
                    ThemedButton(title: "Manage", style: .secondary, size: .small, palette: palette) {
                        isExcludedAppsPresented = true
                    }
                }
            }
        }
        .frame(maxWidth: isCompact ? .infinity : 260, alignment: .leading)
        .sheet(isPresented: $isExcludedAppsPresented) {
            ExcludedAppsSheet(
                settings: settings,
                installedApps: installedApps,
                palette: palette
            )
        }
    }

    private func bindingForApp(_ bundleId: String) -> Binding<Bool> {
        Binding(
            get: { settings.blockedBundleIds.contains(bundleId) },
            set: { isBlocked in
                if isBlocked {
                    settings.blockedBundleIds.insert(bundleId)
                } else {
                    settings.blockedBundleIds.remove(bundleId)
                }
            }
        )
    }

    private func copyToClipboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        switch item.content {
        case .text(let text):
            pasteboard.setString(text, forType: .string)
        case .image(let data):
            if let image = NSImage(data: data) {
                pasteboard.writeObjects([image])
            }
        }
        showToast("Now saved to clipboard")
    }

    private func showToast(_ message: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            toastMessage = message
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeInOut(duration: 0.2)) {
                toastMessage = nil
            }
        }
    }
}

private struct ExcludedAppsSheet: View {
    @ObservedObject var settings: ClipboardSettingsStore
    let installedApps: [InstalledApp]
    let palette: Palette
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [palette.backgroundTop, palette.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Excluded Apps")
                            .font(typography.font(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)
                        Text("Choose apps to ignore clipboard activity.")
                            .font(typography.font(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(palette.textSecondary)
                    }
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(palette.textSecondary)
                            .frame(width: 28, height: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(palette.cardFill)
                            )
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(palette.textSecondary)
                    TextField("Search apps", text: $search)
                        .textFieldStyle(.plain)
                        .font(typography.font(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(palette.panelFill.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(palette.panelStroke, lineWidth: 1)
                        )
                )

                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredApps) { app in
                            ExcludedAppRow(
                                app: app,
                                isBlocked: bindingForApp(app.id),
                                palette: palette
                            )
                            if app.id != filteredApps.last?.id {
                                Divider()
                                    .overlay(palette.divider.opacity(0.6))
                            }
                        }
                        if filteredApps.isEmpty {
                            Text("No apps found.")
                                .font(typography.font(size: 11, weight: .regular, design: .rounded))
                                .foregroundStyle(palette.textSecondary)
                                .padding(.vertical, 6)
                        }
                    }
                }

                Spacer()
            }
            .padding(20)
            .frame(minWidth: 520, minHeight: 420)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(palette.panelFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(palette.panelStroke, lineWidth: 1)
                    )
            )
            .padding(16)
        }
    }

    private var filteredApps: [InstalledApp] {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return installedApps
        }
        return installedApps.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    private func bindingForApp(_ bundleId: String) -> Binding<Bool> {
        Binding(
            get: { settings.blockedBundleIds.contains(bundleId) },
            set: { isBlocked in
                if isBlocked {
                    settings.blockedBundleIds.insert(bundleId)
                } else {
                    settings.blockedBundleIds.remove(bundleId)
                }
            }
        )
    }
}

private struct ExcludedAppRow: View {
    let app: InstalledApp
    let isBlocked: Binding<Bool>
    let palette: Palette
    @State private var isHovering = false
    @EnvironmentObject private var appSettings: AppSettingsStore
    private var typography: AppTypography { AppTypography(settings: appSettings) }

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: app.icon)
                .resizable()
                .renderingMode(.original)
                .frame(width: 18, height: 18)
                .cornerRadius(4)
            Text(app.name)
                .font(typography.font(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.textPrimary)
            Spacer()
            Toggle("", isOn: isBlocked)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(palette.accent)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isBlocked.wrappedValue ? palette.accent.opacity(0.08) : (isHovering ? palette.panelFill.opacity(0.45) : Color.clear))
        )
        .onHover { isHovering = $0 }
    }
}

private struct ClipboardItemRow: View {
    let item: ClipboardItem
    let palette: Palette
    let typography: AppTypography
    let showDivider: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                if let imageData = item.imageData,
                   let image = NSImage(data: imageData) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(palette.panelStroke.opacity(0.7), lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.displayTitle)
                        .font(typography.font(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                        .lineLimit(1)
                    HStack(spacing: 8) {
                        if item.isImage {
                            Text("IMAGE")
                                .font(typography.font(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundStyle(palette.textSecondary)
                        }
                        Text(item.source.uppercased())
                            .font(typography.font(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(palette.textSecondary)
                        Text(item.timestamp)
                            .font(typography.font(size: 10, weight: .regular, design: .rounded))
                            .foregroundStyle(palette.textSecondary)
                    }
                }
                Spacer()
                Button(action: onDelete) {
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
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isHovering ? palette.panelFill.opacity(0.55) : Color.clear)
            )
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelect)
            .onHover { isHovering = $0 }

            if showDivider {
                Divider()
                    .overlay(palette.divider)
            }
        }
    }
}
