public enum MilestoneNotificationMessage {
    private static let encouragementMessages = [
        "힘내세요!",
        "고생하셨습니다.",
        "오늘도 차곡차곡 쌓이고 있어요.",
        "조금만 더 가면 또 쌓입니다.",
        "이미 잘하고 있습니다.",
    ]

    public static func create(
        amountLabel: String,
        randomValue: Double = Double.random(in: 0..<1)
    ) -> String {
        "\(amountLabel) 벌었습니다. \(selectEncouragementMessage(randomValue: randomValue))"
    }

    private static func selectEncouragementMessage(randomValue: Double) -> String {
        let clampedValue = min(0.999_999, max(0, randomValue))
        let slot = Int((clampedValue * Double(encouragementMessages.count)).rounded(.down))
        return encouragementMessages[slot]
    }
}
