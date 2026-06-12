import Foundation
import Combine
import EolmabeomCore

@MainActor
final class EarningsTicker: ObservableObject {
    @Published private(set) var currentTime: Date

    private let input: PayInput
    private var timer: Timer?

    init(input: PayInput, currentTime: Date = Date()) {
        self.input = input
        self.currentTime = currentTime
        start()
    }

    deinit {
        timer?.invalidate()
    }

    var earned: Double {
        PayCalculator.earned(input: input, currentTime: currentTime)
    }

    var amountLabel: String {
        PayCalculator.formatWon(earned)
    }

    var menuBarTitle: String {
        PayCalculator.formatWholeWon(earned)
    }

    private func start() {
        let timer = Timer(timeInterval: 0.125, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.currentTime = Date()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
}
