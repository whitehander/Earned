import AppKit
import SwiftUI

@MainActor
final class SettingsPanelController {
    static let shared = SettingsPanelController()

    private var panel: NSPanel?

    private init() {}

    func show(ticker: EarningsTicker) {
        if let panel {
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 430),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        panel.title = "설정"
        panel.isReleasedWhenClosed = false
        panel.level = .floating
        panel.center()
        panel.contentViewController = NSHostingController(
            rootView: SettingsSheet(ticker: ticker)
        )
        self.panel = panel
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func close() {
        panel?.close()
        panel = nil
    }
}
