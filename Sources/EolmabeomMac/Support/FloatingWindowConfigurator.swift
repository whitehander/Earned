import AppKit
import SwiftUI

struct FloatingWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        configureWhenReady(view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        configureWhenReady(nsView)
    }

    private func configureWhenReady(_ view: NSView) {
        DispatchQueue.main.async {
            guard let window = view.window else {
                return
            }

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
