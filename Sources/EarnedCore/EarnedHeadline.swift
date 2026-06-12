public enum EarnedHeadline {
    public static let rotationIntervalSeconds = 3.0

    public static let messages = [
        "지금까지 번 돈",
        "1일부터 지금까지",
        "여태까지 번 돈",
        "이번 달 생존 보상",
        "이렇게 개고생해서 받은 돈",
        "개미는 뚠뚠, 통장은 찔끔",
        "오늘도 월급을 발굴 중",
        "회사가 준 위로금 누적",
        "내 시간이 녹아서 된 돈",
        "숨만 쉬어도는 아니고 일해서 번 돈",
        "이번 달 노동 마일리지",
        "퇴근 전까지 더 벌 예정",
        "야금야금 쌓인 피땀값",
        "숫자는 오른다, 체력은 내려간다",
        "이것이 나의 노동 그래프",
    ]

    public static func message(at index: Int) -> String {
        let count = messages.count
        let normalizedIndex = ((index % count) + count) % count
        return messages[normalizedIndex]
    }
}
