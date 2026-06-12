import SwiftUI

struct MenuBarAmountView: View {
    let ticker: EarningsTicker

    @ViewBuilder
    var body: some View {
        Text("이번 달 누적")
            .disabled(true)

        Divider()

        Button("설정...") {
            SettingsPanelController.shared.show(ticker: ticker)
        }

        Button("창 앞으로 가져오기") {
            WindowActions.bringAmountWindowToFront()
        }

        Button("종료") {
            WindowActions.terminate()
        }
        .keyboardShortcut("q")
    }
}
