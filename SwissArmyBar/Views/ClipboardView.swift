import SwiftUI

struct ClipboardView: View {
    @Binding var clipboardItems: [ClipboardItem]
    @ObservedObject var settings: ClipboardSettingsStore
    let installedApps: [InstalledApp]
    let isCompact: Bool
    let palette: Palette
    @State private var appSearch = ""

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
        ConfigCard(title: "Recent Clips", palette: palette) {
            HStack {
                Text("Showing last \(settings.historyLimit) items")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
                Spacer()
                Text("\(min(clipboardItems.count, settings.historyLimit)) saved")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.textPrimary)
            }
            let visibleItems = Array(clipboardItems.prefix(settings.historyLimit))
            ForEach(visibleItems) { item in
                VStack(spacing: 8) {
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
                            withAnimation(.easeInOut(duration: 0.2)) {
                                clipboardItems.removeAll { $0.id == item.id }
                            }
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
                    if item.id != visibleItems.last?.id {
                        Divider()
                            .overlay(palette.divider)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: clipboardItems)
    }

    private var clipboardSidePanel: some View {
        VStack(spacing: 16) {
            ConfigCard(title: "Capture", palette: palette, minHeight: 140) {
                HStack {
                    Text("Status")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                    Spacer()
                    Text("Active")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                }
                Text("Listening for text snippets only.")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(palette.textSecondary)
            }

            ConfigCard(title: "Storage", palette: palette, minHeight: 140) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("History limit")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                        Text("Max saved clips")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
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
                    clipboardItems.removeAll()
                }
            }

            ConfigCard(title: "Excluded Apps", palette: palette, minHeight: 220) {
                HStack {
                    Text("Don’t capture from:")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(palette.textSecondary)
                    Spacer()
                    Text("\(settings.blockedBundleIds.count) blocked")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                }

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(palette.textSecondary)
                    TextField("Filter apps", text: $appSearch)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
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
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .foregroundStyle(palette.textSecondary)
                                .padding(.vertical, 6)
                        }
                    }
                }
                .frame(maxHeight: 180)
            }
        }
        .frame(maxWidth: isCompact ? .infinity : 260, alignment: .leading)
    }

    private var filteredApps: [InstalledApp] {
        let query = appSearch.trimmingCharacters(in: .whitespacesAndNewlines)
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

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: app.icon)
                .resizable()
                .renderingMode(.original)
                .frame(width: 18, height: 18)
                .cornerRadius(4)
            Text(app.name)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
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
