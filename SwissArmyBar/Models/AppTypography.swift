import SwiftUI

struct AppTypography {
    let scale: CGFloat
    let choice: AppFontChoice

    init(settings: AppSettingsStore) {
        scale = settings.fontScale
        choice = settings.fontChoice
    }

    func font(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        let scaled = size * scale
        switch choice {
        case .system:
            return .system(size: scaled, weight: weight, design: design)
        case .rounded:
            return .system(size: scaled, weight: weight, design: .rounded)
        case .monospaced:
            return .system(size: scaled, weight: weight, design: .monospaced)
        case .sfMono:
            return .custom("SF Mono", size: scaled).weight(weight)
        case .menlo:
            return .custom("Menlo", size: scaled).weight(weight)
        case .jetbrains:
            return .custom("JetBrains Mono", size: scaled).weight(weight)
        }
    }
}
