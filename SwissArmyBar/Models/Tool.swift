import SwiftUI

enum Tool: String, CaseIterable, Identifiable {
    case clipboard = "Clipboard"
    case focusTimer = "Focus Timer"
    case fileConverter = "File Converter"
    case settings = "Settings"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .clipboard:
            return "doc.on.clipboard"
        case .focusTimer:
            return "timer"
        case .fileConverter:
            return "square.and.arrow.down"
        case .settings:
            return "gearshape"
        }
    }

    var subtitle: String {
        switch self {
        case .clipboard:
            return "Capture and reuse recent text"
        case .focusTimer:
            return "Stay on task with a simple timer"
        case .fileConverter:
            return "Convert compatible files"
        case .settings:
            return "Appearance and preferences"
        }
    }
}
