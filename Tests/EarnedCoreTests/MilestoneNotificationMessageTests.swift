import XCTest
@testable import EarnedCore

final class MilestoneNotificationMessageTests: XCTestCase {
    func testCreatesMilestoneMessageWithFirstWebEncouragement() {
        let message = MilestoneNotificationMessage.create(
            amountLabel: "1,000원",
            randomValue: 0
        )

        XCTAssertEqual(message, "1,000원 벌었습니다. 힘내세요!")
    }

    func testCreatesMilestoneMessageWithLaterWebEncouragement() {
        let message = MilestoneNotificationMessage.create(
            amountLabel: "2,000원",
            randomValue: 0.35
        )

        XCTAssertEqual(message, "2,000원 벌었습니다. 고생하셨습니다.")
    }

    func testClampsOutOfRangeRandomValuesToWebSlots() {
        XCTAssertEqual(
            MilestoneNotificationMessage.create(amountLabel: "3,000원", randomValue: -1),
            "3,000원 벌었습니다. 힘내세요!"
        )
        XCTAssertEqual(
            MilestoneNotificationMessage.create(amountLabel: "4,000원", randomValue: 1),
            "4,000원 벌었습니다. 이미 잘하고 있습니다."
        )
    }
}
