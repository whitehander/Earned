public enum MilestoneNotificationPermissionState: Equatable, Sendable {
    case authorized
    case notDetermined
    case denied
}

public enum MilestoneNotificationPermissionAction: Equatable, Sendable {
    case sendNow
    case requestPermissionThenSend
    case skip
}

public enum MilestoneNotificationSettingsAction: Equatable, Sendable {
    case disabled(label: String)
    case requestPermission(label: String)
    case openSystemSettings(label: String)
}

public enum MilestoneNotificationPermissionPolicy {
    public static func action(
        for state: MilestoneNotificationPermissionState
    ) -> MilestoneNotificationPermissionAction {
        switch state {
        case .authorized:
            .sendNow
        case .notDetermined:
            .requestPermissionThenSend
        case .denied:
            .skip
        }
    }

    public static func settingsAction(
        for state: MilestoneNotificationPermissionState
    ) -> MilestoneNotificationSettingsAction {
        switch state {
        case .authorized:
            .disabled(label: "알림 켜져있음")
        case .notDetermined:
            .requestPermission(label: "알림 켜기")
        case .denied:
            .openSystemSettings(label: "알림 설정 열기")
        }
    }
}
