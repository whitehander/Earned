import SwiftUI
import EolmabeomCore

@main
struct EolmabeomMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var ticker = EarningsTicker(input: PaySettingsStore.load())
    @StateObject private var appState = AppState.shared

    var body: some Scene {
        WindowGroup("오늘까지 얼마범?") {
            FloatingAmountWindow(
                ticker: ticker,
                appState: appState
            )
            .frame(
                minWidth: 240,
                idealWidth: 300,
                minHeight: 96,
                idealHeight: 116
            )
        }
        .defaultSize(width: 300, height: 116)
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
