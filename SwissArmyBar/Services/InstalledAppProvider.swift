import AppKit
import Foundation

enum InstalledAppProvider {
    static func loadInstalledApps() -> [InstalledApp] {
        let fileManager = FileManager.default
        let directories: [URL] = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: "/System/Applications"),
            URL(fileURLWithPath: "/System/Library/CoreServices"),
            URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Applications")
        ]

        var appsByBundleId: [String: InstalledApp] = [:]

        for directory in directories {
            guard let topLevel = try? fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { continue }

            let candidates = topLevel + topLevel.flatMap { subdir -> [URL] in
                guard (try? subdir.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else {
                    return []
                }
                return (try? fileManager.contentsOfDirectory(
                    at: subdir,
                    includingPropertiesForKeys: [.isDirectoryKey],
                    options: [.skipsHiddenFiles]
                )) ?? []
            }

            for appURL in candidates where appURL.pathExtension == "app" {
                guard let bundle = Bundle(url: appURL),
                      let bundleId = bundle.bundleIdentifier else { continue }

                let name = (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
                    ?? (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)
                    ?? appURL.deletingPathExtension().lastPathComponent

                let icon = NSWorkspace.shared.icon(forFile: appURL.path)
                appsByBundleId[bundleId] = InstalledApp(
                    id: bundleId,
                    name: name,
                    url: appURL,
                    icon: icon
                )
            }
        }

        return appsByBundleId.values.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
