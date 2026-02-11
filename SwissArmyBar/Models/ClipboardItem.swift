import Foundation

enum ClipboardContent: Equatable {
    case text(String)
    case image(Data)
}

struct ClipboardItem: Identifiable, Equatable {
    let id = UUID()
    let content: ClipboardContent
    let source: String
    let timestamp: String

    var displayTitle: String {
        switch content {
        case .text(let text):
            return text
        case .image:
            return "Image"
        }
    }

    var textValue: String? {
        switch content {
        case .text(let text):
            return text
        case .image:
            return nil
        }
    }

    var imageData: Data? {
        switch content {
        case .image(let data):
            return data
        case .text:
            return nil
        }
    }

    var isImage: Bool {
        if case .image = content { return true }
        return false
    }
}
