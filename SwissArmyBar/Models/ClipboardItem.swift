import Foundation

struct ClipboardItem: Identifiable {
    let id = UUID()
    let text: String
    let source: String
    let timestamp: String
}
