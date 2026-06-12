import XCTest
@testable import EarnedCore

final class EarnedHeadlineTests: XCTestCase {
    func testHeadlineRotationHasEnoughEarnedMoneyPhrases() {
        XCTAssertGreaterThanOrEqual(EarnedHeadline.messages.count, 11)
        XCTAssertTrue(EarnedHeadline.messages.contains("지금까지 번 돈"))
        XCTAssertTrue(EarnedHeadline.messages.contains("1일부터 지금까지"))
        XCTAssertTrue(EarnedHeadline.messages.contains("이렇게 개고생해서 받은 돈"))
        XCTAssertTrue(EarnedHeadline.messages.contains("개미는 뚠뚠, 통장은 찔끔"))
    }

    func testHeadlineLookupWrapsAroundBothDirections() {
        XCTAssertEqual(EarnedHeadline.message(at: 0), "지금까지 번 돈")
        XCTAssertEqual(EarnedHeadline.message(at: EarnedHeadline.messages.count), "지금까지 번 돈")
        XCTAssertEqual(EarnedHeadline.message(at: -1), EarnedHeadline.messages.last)
    }
}
