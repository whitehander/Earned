import SwiftUI

struct MenuBarAmountView: View {
    @ObservedObject var ticker: EarningsTicker

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ticker.amountLabel)
                .font(.headline)
                .monospacedDigit()
                .contentTransition(.numericText())

            Text("이번 달 누적")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Button("창 앞으로 가져오기") {
                WindowActions.bringAmountWindowToFront()
            }

            Button("종료") {
                WindowActions.terminate()
            }
            .keyboardShortcut("q")
        }
        .padding(.vertical, 4)
    }
}
