import SwiftUI
import EarnedCore

struct FloatingAmountWindow: View {
    @ObservedObject var ticker: EarningsTicker
    @ObservedObject var appState: AppState
    @State private var isHovering = false
    @State private var headlineIndex = 0
    private let headlineTimer = Timer.publish(
        every: EarnedHeadline.rotationIntervalSeconds,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 6) {
                    Text(EarnedHeadline.message(at: headlineIndex))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                        .frame(maxWidth: .infinity)
                        .id(headlineIndex)
                        .transition(.opacity)

                    AnimatedAmountText(
                        label: ticker.amountLabel,
                        fontSize: amountFontSize(for: geometry.size)
                    )
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

                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.tertiary)
                    .opacity(isHovering ? 1 : 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(9)
            }
        }
        .background(
            Color(nsColor: .controlBackgroundColor),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .background(HoverTrackingView(isHovering: $isHovering))
        .background(FloatingWindowConfigurator())
        .sheet(isPresented: $appState.isSettingsPresented) {
            SettingsSheet(ticker: ticker)
        }
        .onReceive(headlineTimer) { _ in
            headlineIndex = (headlineIndex + 1) % EarnedHeadline.messages.count
        }
        .animation(.easeInOut(duration: 0.22), value: headlineIndex)
    }

    private func amountFontSize(for size: CGSize) -> CGFloat {
        max(28, min(156, min(size.width * 0.23, size.height * 0.62)))
    }
}
