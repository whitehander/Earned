import SwiftUI

struct MenuBarAmountLabel: View {
    let label: String
    let date: Date

    var body: some View {
        AnimatedAmountText(
            label: label,
            fontSize: 13,
            presentation: .menuBar,
            referenceDate: date
        )
        .frame(width: width, height: 18)
        .accessibilityLabel(label)
    }

    private var width: CGFloat {
        min(max(CGFloat(label.count) * 8.2, 76), 168)
    }
}

struct MenuBarAmountView: View {
    let ticker: EarningsTicker

    @ViewBuilder
    var body: some View {
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
