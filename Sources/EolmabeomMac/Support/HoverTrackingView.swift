import AppKit
import SwiftUI

struct HoverTrackingView: NSViewRepresentable {
    @Binding var isHovering: Bool

    func makeCoordinator() -> HoverCoordinator {
        HoverCoordinator(isHovering: $isHovering)
    }

    func makeNSView(context: Context) -> HoverProbeView {
        let view = HoverProbeView()
        view.coordinator = context.coordinator
        return view
    }

    func updateNSView(_ nsView: HoverProbeView, context: Context) {
        context.coordinator.isHovering = $isHovering
        context.coordinator.attach(to: nsView.window)
    }
}

final class HoverProbeView: NSView {
    weak var coordinator: HoverCoordinator?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        coordinator?.attach(to: window)
    }
}

final class HoverCoordinator: NSObject {
    var isHovering: Binding<Bool>

    private weak var window: NSWindow?
    private weak var trackedContentView: NSView?
    private var trackingArea: NSTrackingArea?
    private var localMonitor: Any?
    private var globalMonitor: Any?
    private var pollTimer: Timer?

    init(isHovering: Binding<Bool>) {
        self.isHovering = isHovering
        super.init()
        installMouseMonitors()
        installPollTimer()
    }

    deinit {
        pollTimer?.invalidate()
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }
    }

    func attach(to window: NSWindow?) {
        guard self.window !== window else {
            refreshHoverState()
            return
        }

        removeTrackingArea()
        self.window = window
        window?.acceptsMouseMovedEvents = true

        guard let contentView = window?.contentView else {
            return
        }

        let area = NSTrackingArea(
            rect: .zero,
            options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        contentView.addTrackingArea(area)
        trackedContentView = contentView
        trackingArea = area
        refreshHoverState()
    }

    func mouseEntered(with event: NSEvent) {
        setHovering(true)
    }

    func mouseMoved(with event: NSEvent) {
        refreshHoverState()
    }

    func mouseExited(with event: NSEvent) {
        refreshHoverState()
    }

    private func installMouseMonitors() {
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged]) {
            [weak self] event in
            self?.refreshHoverState()
            return event
        }
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged]) {
            [weak self] _ in
            self?.refreshHoverState()
        }
    }

    private func installPollTimer() {
        let timer = Timer(timeInterval: 0.15, repeats: true) { [weak self] _ in
            self?.refreshHoverState()
        }
        RunLoop.main.add(timer, forMode: .common)
        pollTimer = timer
    }

    private func refreshHoverState() {
        guard let window else {
            setHovering(false)
            return
        }

        setHovering(window.frame.contains(NSEvent.mouseLocation))
    }

    private func setHovering(_ hovering: Bool) {
        guard isHovering.wrappedValue != hovering else {
            return
        }

        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.12)) {
                self.isHovering.wrappedValue = hovering
            }
        }
    }

    private func removeTrackingArea() {
        guard let trackedContentView, let trackingArea else {
            return
        }

        trackedContentView.removeTrackingArea(trackingArea)
        self.trackingArea = nil
        self.trackedContentView = nil
    }
}
