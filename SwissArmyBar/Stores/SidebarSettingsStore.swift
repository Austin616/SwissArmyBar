import Foundation

final class SidebarSettingsStore: ObservableObject {
    @Published var favorites: [Tool] {
        didSet { save() }
    }
    @Published var tools: [Tool] {
        didSet { save() }
    }

    private let defaults: UserDefaults
    private let storageKey = "sidebarPreferences.v1"
    private var isLoaded = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let allTools = Tool.allCases
        let defaultFavorites: [Tool] = [.clipboard, .focusTimer]

        if let data = defaults.data(forKey: storageKey),
           let prefs = try? JSONDecoder().decode(SidebarPreferences.self, from: data) {
            let loadedFavorites = prefs.favoriteToolIds.compactMap { Tool(rawValue: $0) }
            let loadedTools = prefs.toolsOrder.compactMap { Tool(rawValue: $0) }

            let uniqueFavorites = Array(NSOrderedSet(array: loadedFavorites)) as? [Tool] ?? []
            let uniqueTools = Array(NSOrderedSet(array: loadedTools)) as? [Tool] ?? []

            favorites = uniqueFavorites.isEmpty ? defaultFavorites : uniqueFavorites
            tools = uniqueTools.filter { !favorites.contains($0) }

            let missing = allTools.filter { !favorites.contains($0) && !tools.contains($0) }
            tools.append(contentsOf: missing)
        } else {
            favorites = defaultFavorites
            tools = allTools.filter { !defaultFavorites.contains($0) }
        }

        isLoaded = true
    }

    func isFavorite(_ tool: Tool) -> Bool {
        favorites.contains(tool)
    }

    func toggleFavorite(_ tool: Tool) {
        if let index = favorites.firstIndex(of: tool) {
            favorites.remove(at: index)
            if !tools.contains(tool) {
                tools.append(tool)
            }
        } else {
            favorites.append(tool)
            tools.removeAll { $0 == tool }
        }
    }

    func moveFavorite(dragged: Tool, over target: Tool) {
        reorder(dragged: dragged, over: target, in: &favorites)
    }

    func moveTool(dragged: Tool, over target: Tool) {
        reorder(dragged: dragged, over: target, in: &tools)
    }

    private func reorder(dragged: Tool, over target: Tool, in list: inout [Tool]) {
        guard dragged != target,
              let fromIndex = list.firstIndex(of: dragged),
              let toIndex = list.firstIndex(of: target) else { return }

        var updated = list
        let item = updated.remove(at: fromIndex)
        let insertIndex = toIndex > fromIndex ? toIndex - 1 : toIndex
        updated.insert(item, at: insertIndex)
        list = updated
    }

    private func save() {
        guard isLoaded else { return }
        let prefs = SidebarPreferences(
            favoriteToolIds: favorites.map(\.rawValue),
            toolsOrder: tools.map(\.rawValue)
        )
        if let data = try? JSONEncoder().encode(prefs) {
            defaults.set(data, forKey: storageKey)
        }
    }
}

private struct SidebarPreferences: Codable {
    let favoriteToolIds: [String]
    let toolsOrder: [String]
}
