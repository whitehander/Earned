import AppKit

enum WindowActions {
    static func bringAmountWindowToFront() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows
            .filter(\.canBecomeKey)
            .first?
            .makeKeyAndOrderFront(nil)
    }

    static func terminate() {
        NSApp.terminate(nil)
    }
}
