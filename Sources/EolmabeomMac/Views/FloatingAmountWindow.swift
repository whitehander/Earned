import SwiftUI

struct FloatingAmountWindow: View {
    @ObservedObject var ticker: EarningsTicker
    @State private var isHovering = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 6) {
                Text("오늘까지 얼마범?")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(ticker.amountLabel)
                    .font(.system(size: 39, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.54)
                    .lineLimit(1)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                WindowActions.terminate()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 19, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("종료")
            .opacity(isHovering ? 1 : 0)
            .allowsHitTesting(isHovering)
            .padding(9)
        }
        .background(
            Color(nsColor: .controlBackgroundColor),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .background(HoverTrackingView(isHovering: $isHovering))
        .background(FloatingWindowConfigurator())
    }
}
