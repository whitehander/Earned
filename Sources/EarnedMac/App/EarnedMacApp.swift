import SwiftUI
import EarnedCore

@main
struct EarnedMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var ticker = EarningsTicker(input: PaySettingsStore.load())

    var body: some Scene {
        WindowGroup("얼마범") {
            FloatingAmountWindow(ticker: ticker)
            .frame(
                minWidth: 240,
                idealWidth: 300,
                minHeight: 96,
                idealHeight: 116
            )
        }
        .defaultSize(width: 300, height: 116)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("설정...") {
                    SettingsPanelController.shared.show(ticker: ticker)
                }
                .keyboardShortcut(",", modifiers: .command)
            }

            CommandGroup(before: .windowSize) {
                Button("창 숨기기") {
                    WindowActions.hideAmountWindow()
                }
                .keyboardShortcut("w", modifiers: .command)
            }
        }

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
