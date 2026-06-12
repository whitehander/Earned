import SwiftUI
import EarnedCore

@main
struct EarnedMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var ticker = EarningsTicker(input: PaySettingsStore.load())
    @StateObject private var appState = AppState.shared

    var body: some Scene {
        WindowGroup("얼마범") {
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
            MenuBarAmountLabel(
                label: ticker.menuBarTitle,
                date: ticker.currentTime
            )
        }
        .menuBarExtraStyle(.menu)
    }
}
