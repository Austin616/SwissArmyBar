import SwiftUI
import Combine

enum TimeUnitStyle: String, CaseIterable, Identifiable {
    case short
    case long

    var id: String { rawValue }

    var label: String {
        switch self {
        case .short:
            return "min"
        case .long:
            return "minutes"
        }
    }
}

enum AppFontChoice: String, CaseIterable, Identifiable {
    case system
    case rounded
    case monospaced
    case sfMono
    case menlo
    case jetbrains

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            return "System"
        case .rounded:
            return "System Rounded"
        case .monospaced:
            return "System Mono"
        case .sfMono:
            return "SF Mono"
        case .menlo:
            return "Menlo"
        case .jetbrains:
            return "JetBrains Mono"
        }
    }

    var fontName: String? {
        switch self {
        case .system, .rounded, .monospaced:
            return nil
        case .sfMono:
            return "SF Mono"
        case .menlo:
            return "Menlo"
        case .jetbrains:
            return "JetBrains Mono"
        }
    }
}

final class AppSettingsStore: ObservableObject {
    private let defaults: UserDefaults
    private let storageKey = "appPreferences.v1"
    private var isLoaded = false

    @Published var timeUnitStyle: TimeUnitStyle {
        didSet { save() }
    }
    @Published var fontChoice: AppFontChoice {
        didSet { save() }
    }
    @Published var fontScalePercent: Int {
        didSet {
            let clamped = min(max(fontScalePercent, 80), 130)
            if fontScalePercent != clamped {
                fontScalePercent = clamped
                return
            }
            save()
        }
    }
    @Published var menuBarClipboardLimit: Int {
        didSet {
            let clamped = min(max(menuBarClipboardLimit, 3), 20)
            if menuBarClipboardLimit != clamped {
                menuBarClipboardLimit = clamped
                return
            }
            save()
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: storageKey),
           let prefs = try? JSONDecoder().decode(AppPreferences.self, from: data) {
            timeUnitStyle = TimeUnitStyle(rawValue: prefs.timeUnitStyle) ?? .short
            fontChoice = AppFontChoice(rawValue: prefs.fontChoice) ?? .system
            fontScalePercent = min(max(prefs.fontScalePercent, 80), 130)
            menuBarClipboardLimit = min(max(prefs.menuBarClipboardLimit, 3), 20)
        } else {
            timeUnitStyle = .short
            fontChoice = .system
            fontScalePercent = 100
            menuBarClipboardLimit = 8
        }

        isLoaded = true
    }

    var fontScale: CGFloat {
        CGFloat(fontScalePercent) / 100
    }

    private func save() {
        guard isLoaded else { return }
        let prefs = AppPreferences(
            timeUnitStyle: timeUnitStyle.rawValue,
            fontChoice: fontChoice.rawValue,
            fontScalePercent: fontScalePercent,
            menuBarClipboardLimit: menuBarClipboardLimit
        )
        if let data = try? JSONEncoder().encode(prefs) {
            defaults.set(data, forKey: storageKey)
        }
    }
}

private struct AppPreferences: Codable {
    let timeUnitStyle: String
    let fontChoice: String
    let fontScalePercent: Int
    let menuBarClipboardLimit: Int

    init(timeUnitStyle: String, fontChoice: String, fontScalePercent: Int, menuBarClipboardLimit: Int) {
        self.timeUnitStyle = timeUnitStyle
        self.fontChoice = fontChoice
        self.fontScalePercent = fontScalePercent
        self.menuBarClipboardLimit = menuBarClipboardLimit
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeUnitStyle = try container.decodeIfPresent(String.self, forKey: .timeUnitStyle) ?? TimeUnitStyle.short.rawValue
        fontChoice = try container.decodeIfPresent(String.self, forKey: .fontChoice) ?? AppFontChoice.system.rawValue
        fontScalePercent = try container.decodeIfPresent(Int.self, forKey: .fontScalePercent) ?? 100
        menuBarClipboardLimit = try container.decodeIfPresent(Int.self, forKey: .menuBarClipboardLimit) ?? 8
    }
}
