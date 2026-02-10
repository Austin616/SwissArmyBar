//
//  SwissArmyBarApp.swift
//  SwissArmyBar
//
//  Created by Austin Tran on 2/10/26.
//

import SwiftUI

@main
struct SwissArmyBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var environment = AppEnvironment()

    init() {
        appDelegate.appEnvironment = environment
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(environment.appSettings)
                .environmentObject(environment.clipboardSettings)
                .environmentObject(environment.clipboardMonitor)
                .environmentObject(environment.sidebarSettings)
                .environmentObject(environment.timerStore)
        }
        .defaultSize(width: 1024, height: 700)
        .windowResizability(.contentMinSize)
    }
}
