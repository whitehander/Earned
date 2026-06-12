import AppKit

enum WindowActions {
    static let amountWindowIdentifier = NSUserInterfaceItemIdentifier("earned.amountWindow")

    static func bringAmountWindowToFront() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows
            .first { $0.identifier == amountWindowIdentifier }?
            .makeKeyAndOrderFront(nil)
    }

    static func hideAmountWindow() {
        NSApp.windows
            .first { $0.identifier == amountWindowIdentifier }?
            .orderOut(nil)
    }

    static func terminate() {
        NSApp.terminate(nil)
    }
}
