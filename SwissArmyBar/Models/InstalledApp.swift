import AppKit

struct InstalledApp: Identifiable {
    let id: String
    let name: String
    let url: URL
    let icon: NSImage
}
