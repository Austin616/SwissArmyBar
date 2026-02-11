import Foundation
import Combine

final class AppEnvironment: ObservableObject {
    let appSettings: AppSettingsStore
    let clipboardSettings: ClipboardSettingsStore
    let clipboardMonitor: ClipboardMonitor
    let sidebarSettings: SidebarSettingsStore
    let timerStore: TimerStore
    let themeStore: ThemeStore

    init() {
        let clipboardSettings = ClipboardSettingsStore()
        self.clipboardSettings = clipboardSettings
        self.clipboardMonitor = ClipboardMonitor(settings: clipboardSettings)
        self.sidebarSettings = SidebarSettingsStore()
        self.appSettings = AppSettingsStore()
        self.timerStore = TimerStore()
        self.themeStore = ThemeStore(presets: ThemeCatalog.presets)
    }
}
