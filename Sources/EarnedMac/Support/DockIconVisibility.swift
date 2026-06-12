import AppKit
import Foundation

enum DockIconVisibility {
    static let hideDockIconKey = "earned.hideDockIcon"

    static func applyStoredPreference() {
        apply(hidesDockIcon: UserDefaults.standard.bool(forKey: hideDockIconKey))
    }

    static func apply(hidesDockIcon: Bool) {
        NSApp.setActivationPolicy(hidesDockIcon ? .accessory : .regular)
        if !hidesDockIcon {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
