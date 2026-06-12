import AppKit
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    private var closeShortcutMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        DockIconVisibility.applyStoredPreference()
        UNUserNotificationCenter.current().delegate = self
        installCloseShortcutMonitor()
        installCloseMenuOverride()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    private func installCloseShortcutMonitor() {
        closeShortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let keyWindow = NSApp.keyWindow
            guard event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.command),
                  event.charactersIgnoringModifiers == "w",
                  keyWindow == nil || keyWindow?.identifier == WindowActions.amountWindowIdentifier
            else {
                return event
            }

            WindowActions.hideAmountWindow()
            return nil
        }
    }

    private func installCloseMenuOverride() {
        DispatchQueue.main.async {
            NSApp.mainMenu?.items
                .compactMap(\.submenu)
                .flatMap(\.items)
                .filter { item in
                    item.keyEquivalent == "w"
                        && item.keyEquivalentModifierMask
                            .intersection(.deviceIndependentFlagsMask)
                            .contains(.command)
                }
                .forEach { item in
                    item.title = "창 숨기기"
                    item.target = self
                    item.action = #selector(Self.hideAmountWindowFromMenu(_:))
                }
        }
    }

    @objc private func hideAmountWindowFromMenu(_ sender: NSMenuItem) {
        WindowActions.hideAmountWindow()
    }
}
