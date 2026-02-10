import Foundation

struct ClipboardApp: Identifiable, Hashable {
    let id: String
    let name: String
    var isBlocked: Bool

    init(name: String, bundleId: String, isBlocked: Bool = false) {
        self.name = name
        self.id = bundleId
        self.isBlocked = isBlocked
    }
}
