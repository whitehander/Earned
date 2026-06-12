import AppKit
import SwiftUI

struct FloatingWindowConfigurator: NSViewRepresentable {
    func makeCoordinator() -> FloatingWindowCoordinator {
        FloatingWindowCoordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        configureWhenReady(view, coordinator: context.coordinator)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        configureWhenReady(nsView, coordinator: context.coordinator)
    }

    private func configureWhenReady(_ view: NSView, coordinator: FloatingWindowCoordinator) {
        DispatchQueue.main.async {
            guard let window = view.window else {
                return
            }

            window.identifier = WindowActions.amountWindowIdentifier
            window.delegate = coordinator
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.styleMask = [.borderless, .resizable]
            window.minSize = NSSize(width: 240, height: 96)
            window.isMovableByWindowBackground = true
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = true
        }
    }
}

final class FloatingWindowCoordinator: NSObject, NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }
}
