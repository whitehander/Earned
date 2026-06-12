import Foundation
import Combine
import UserNotifications
import EolmabeomCore

@MainActor
final class EarningsTicker: ObservableObject {
    @Published private(set) var currentTime: Date
    @Published private(set) var input: PayInput

    private var timer: Timer?
    private var lastMilestoneAmount: Double

    init(input: PayInput, currentTime: Date = Date()) {
        self.input = input
        self.currentTime = currentTime
        self.lastMilestoneAmount = Self.lastMilestoneAmount(input: input, currentTime: currentTime)
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

    func apply(_ input: PayInput) {
        self.input = input
        currentTime = Date()
        lastMilestoneAmount = Self.lastMilestoneAmount(input: input, currentTime: currentTime)
        PaySettingsStore.save(input)
    }

    private func start() {
        let timer = Timer(timeInterval: 0.125, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func tick() {
        currentTime = Date()
        sendMilestoneNotificationIfNeeded()
    }

    private func sendMilestoneNotificationIfNeeded() {
        guard earned >= input.alertUnit else {
            return
        }

        let reachedAmount = floor(earned / input.alertUnit) * input.alertUnit
        guard reachedAmount > lastMilestoneAmount else {
            return
        }

        lastMilestoneAmount = reachedAmount
        let content = UNMutableNotificationContent()
        content.title = "오늘까지 얼마범?"
        content.body = "\(PayCalculator.formatWholeWon(reachedAmount)) 벌었습니다. 힘내세요!"
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "eolmabeom-\(Int(reachedAmount))",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    private static func lastMilestoneAmount(input: PayInput, currentTime: Date) -> Double {
        floor(PayCalculator.earned(input: input, currentTime: currentTime) / input.alertUnit)
            * input.alertUnit
    }
}
