import SwiftUI
import EolmabeomCore

@main
struct EolmabeomMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var ticker = EarningsTicker(input: .defaultValue)

    var body: some Scene {
        WindowGroup("오늘까지 얼마범?") {
            FloatingAmountWindow(ticker: ticker)
                .frame(width: 300, height: 116)
        }
        .defaultSize(width: 300, height: 116)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)

        MenuBarExtra {
            MenuBarAmountView(ticker: ticker)
        } label: {
            Text(ticker.menuBarTitle)
                .monospacedDigit()
        }
        .menuBarExtraStyle(.menu)
    }
}
