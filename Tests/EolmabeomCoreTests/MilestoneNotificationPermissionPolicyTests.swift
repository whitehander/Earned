import XCTest
@testable import EolmabeomCore

final class MilestoneNotificationPermissionPolicyTests: XCTestCase {
    func testSendsImmediatelyWhenNotificationsAreAuthorized() {
        XCTAssertEqual(
            MilestoneNotificationPermissionPolicy.action(for: .authorized),
            .sendNow
        )
    }

    func testRequestsPermissionBeforeSendingWhenNotificationStateIsNotDetermined() {
        XCTAssertEqual(
            MilestoneNotificationPermissionPolicy.action(for: .notDetermined),
            .requestPermissionThenSend
        )
    }

    func testSkipsNotificationWhenPermissionIsDenied() {
        XCTAssertEqual(
            MilestoneNotificationPermissionPolicy.action(for: .denied),
            .skip
        )
    }

    func testSettingsButtonRequestsPermissionWhenNotificationStateIsNotDetermined() {
        XCTAssertEqual(
            MilestoneNotificationPermissionPolicy.settingsAction(for: .notDetermined),
            .requestPermission(label: "알림 켜기")
        )
    }

    func testSettingsButtonOpensSystemSettingsWhenNotificationStateIsDenied() {
        XCTAssertEqual(
            MilestoneNotificationPermissionPolicy.settingsAction(for: .denied),
            .openSystemSettings(label: "알림 설정 열기")
        )
    }

    func testSettingsButtonIsDisabledWhenNotificationsAreAuthorized() {
        XCTAssertEqual(
            MilestoneNotificationPermissionPolicy.settingsAction(for: .authorized),
            .disabled(label: "알림 켜져있음")
        )
    }
}
