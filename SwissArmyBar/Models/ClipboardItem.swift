import Foundation

struct ClipboardItem: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let source: String
    let timestamp: String
}
