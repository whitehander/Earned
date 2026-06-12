import SwiftUI

struct AnimatedAmountText: View {
    let label: String
    let fontSize: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation) { timeline in
            let state = animationState(at: timeline.date)
            let progress = reduceMotion ? 0.5 : state.gradientProgress

            ZStack {
                amountText
                    .foregroundStyle(glowGradient(progress: progress))
                    .blur(radius: reduceMotion ? 8 : state.glowBlur)
                    .opacity(reduceMotion ? 0.36 : state.glowOpacity)
                    .scaleEffect(reduceMotion ? 1.02 : state.glowScale)
                    .blendMode(.screen)

                amountText
                    .foregroundStyle(textGradient(progress: progress))
                    .shadow(
                        color: amountHighlight.opacity(reduceMotion ? 0.16 : state.shadowOpacity),
                        radius: reduceMotion ? 18 : state.shadowRadius,
                        x: 0,
                        y: reduceMotion ? 12 : state.shadowY
                    )
            }
            .compositingGroup()
            .scaleEffect(reduceMotion ? 1 : state.scale)
            .offset(y: reduceMotion ? 0 : state.yOffset)
        }
    }

    private var amountText: some View {
        Text(label)
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.42)
            .allowsTightening(true)
    }

    private func textGradient(progress: Double) -> LinearGradient {
        let center = min(max(progress, 0), 1)
        let coreWidth = 0.07
        let featherWidth = 0.24
        let stops = [
            Gradient.Stop(color: amountBase, location: 0),
            Gradient.Stop(color: amountBase, location: max(0, center - featherWidth)),
            Gradient.Stop(color: amountHighlight, location: max(0, center - coreWidth)),
            Gradient.Stop(color: amountHighlight, location: min(1, center + coreWidth)),
            Gradient.Stop(color: amountBase, location: min(1, center + featherWidth)),
            Gradient.Stop(color: amountBase, location: 1),
        ]

        return LinearGradient(
            stops: stops,
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func glowGradient(progress: Double) -> LinearGradient {
        let center = min(max(progress, 0), 1)
        let stops = [
            Gradient.Stop(color: amountHighlight.opacity(0.16), location: 0),
            Gradient.Stop(color: amountHighlight.opacity(0.22), location: max(0, center - 0.34)),
            Gradient.Stop(color: amountHighlight.opacity(0.78), location: max(0, center - 0.1)),
            Gradient.Stop(color: amountHighlight.opacity(0.9), location: min(1, center + 0.1)),
            Gradient.Stop(color: amountHighlight.opacity(0.22), location: min(1, center + 0.34)),
            Gradient.Stop(color: amountHighlight.opacity(0.16), location: 1),
        ]

        return LinearGradient(
            stops: stops,
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func animationState(at date: Date) -> AmountAnimationState {
        let flow = cssKeyframeProgress(
            seconds: date.timeIntervalSinceReferenceDate,
            duration: 2.2
        )
        let pulseProgress = date.timeIntervalSinceReferenceDate
            .truncatingRemainder(dividingBy: 0.9) / 0.9
        let pulse = cssPulse(progress: pulseProgress)

        return AmountAnimationState(
            gradientProgress: flow,
            scale: pulse.scale,
            yOffset: pulse.yOffset,
            shadowRadius: pulse.shadowRadius,
            shadowY: pulse.shadowY,
            shadowOpacity: pulse.shadowOpacity,
            glowBlur: pulse.glowBlur,
            glowScale: pulse.glowScale,
            glowOpacity: pulse.glowOpacity
        )
    }

    private func cssKeyframeProgress(seconds: TimeInterval, duration: TimeInterval) -> Double {
        let progress = seconds.truncatingRemainder(dividingBy: duration) / duration
        if progress <= 0.52 {
            return easeInOut(progress / 0.52)
        }

        return 1 - easeInOut((progress - 0.52) / 0.48)
    }

    private var amountHighlight: Color {
        Color(red: 0.06, green: 0.38, blue: 1)
    }

    private var amountBase: Color {
        .white
    }

    private func cssPulse(progress: Double) -> AmountPulseState {
        if progress <= 0.48 {
            let eased = cubicEaseOut(progress / 0.48)
            return AmountPulseState(
                scale: interpolate(from: 0.992, to: 1.01, progress: eased),
                yOffset: interpolate(from: 2, to: -3, progress: eased),
                shadowRadius: interpolate(from: 24, to: 34, progress: eased),
                shadowY: interpolate(from: 18, to: 26, progress: eased),
                shadowOpacity: interpolate(from: 0.18, to: 0.34, progress: eased),
                glowBlur: interpolate(from: 9, to: 15, progress: eased),
                glowScale: interpolate(from: 1.018, to: 1.04, progress: eased),
                glowOpacity: interpolate(from: 0.34, to: 0.58, progress: eased)
            )
        }

        let eased = cubicEaseOut((progress - 0.48) / 0.52)
        return AmountPulseState(
            scale: interpolate(from: 1.01, to: 1, progress: eased),
            yOffset: interpolate(from: -3, to: 0, progress: eased),
            shadowRadius: interpolate(from: 34, to: 24, progress: eased),
            shadowY: interpolate(from: 26, to: 18, progress: eased),
            shadowOpacity: interpolate(from: 0.34, to: 0.18, progress: eased),
            glowBlur: interpolate(from: 15, to: 9, progress: eased),
            glowScale: interpolate(from: 1.04, to: 1.018, progress: eased),
            glowOpacity: interpolate(from: 0.58, to: 0.34, progress: eased)
        )
    }

    private func easeInOut(_ progress: Double) -> Double {
        0.5 - (cos(progress * .pi) * 0.5)
    }

    private func cubicEaseOut(_ progress: Double) -> Double {
        1 - pow(1 - progress, 3)
    }

    private func interpolate(from start: Double, to end: Double, progress: Double) -> Double {
        start + ((end - start) * progress)
    }
}

private struct AmountAnimationState {
    let gradientProgress: Double
    let scale: Double
    let yOffset: Double
    let shadowRadius: Double
    let shadowY: Double
    let shadowOpacity: Double
    let glowBlur: Double
    let glowScale: Double
    let glowOpacity: Double
}

private struct AmountPulseState {
    let scale: Double
    let yOffset: Double
    let shadowRadius: Double
    let shadowY: Double
    let shadowOpacity: Double
    let glowBlur: Double
    let glowScale: Double
    let glowOpacity: Double
}
