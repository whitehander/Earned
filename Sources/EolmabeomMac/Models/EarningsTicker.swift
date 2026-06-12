import Foundation
import Combine
import OSLog
@preconcurrency import UserNotifications
import EolmabeomCore

private let notificationLogger = Logger(
    subsystem: "com.whitehander.eolmabeom.mac",
    category: "notifications"
)

@MainActor
final class EarningsTicker: ObservableObject {
    @Published private(set) var currentTime: Date
    @Published private(set) var input: PayInput

    private var timer: Timer?
    private var lastMilestoneAmount: Double
    private var isRequestingNotificationPermission = false
    private var didFailAutomaticNotificationPermissionRequest = false
    private var notificationPermissionRetryDate: Date?
    private var cachedNotificationPermissionState: MilestoneNotificationPermissionState?
    private let notificationPermissionRetryInterval: TimeInterval = 30

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

    func resetNotificationPermissionBackoff() {
        didFailAutomaticNotificationPermissionRequest = false
        notificationPermissionRetryDate = nil
    }

    func updateNotificationPermissionState(_ state: MilestoneNotificationPermissionState) {
        cachedNotificationPermissionState = state
        if state != .denied {
            resetNotificationPermissionBackoff()
        }
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
        sendMilestoneNotification(reachedAmount: reachedAmount)
    }

    private func sendMilestoneNotification(reachedAmount: Double) {
        guard shouldCheckNotificationPermission else {
            return
        }

        let identifier = "eolmabeom-\(Int(reachedAmount))"
        let body = MilestoneNotificationMessage.create(
            amountLabel: PayCalculator.formatWholeWon(reachedAmount)
        )

        if cachedNotificationPermissionState == .authorized {
            sendMilestoneNotification(
                identifier: identifier,
                body: body,
                permissionState: .authorized
            )
            return
        }

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            notificationLogger.info(
                "Milestone notification settings status: \(settings.authorizationStatus.rawValue, privacy: .public)"
            )
            Task { @MainActor in
                guard let self else {
                    return
                }

                let permissionState = Self.permissionState(from: settings.authorizationStatus)
                self.cachedNotificationPermissionState = permissionState
                self.sendMilestoneNotification(
                    identifier: identifier,
                    body: body,
                    permissionState: permissionState
                )
            }
        }
    }

    private func sendMilestoneNotification(
        identifier: String,
        body: String,
        permissionState: MilestoneNotificationPermissionState
    ) {
        switch MilestoneNotificationPermissionPolicy.action(for: permissionState) {
        case .sendNow:
            resetNotificationPermissionBackoff()
            Self.addNotification(identifier: identifier, body: body)
        case .requestPermissionThenSend:
            guard !isRequestingNotificationPermission,
                  !didFailAutomaticNotificationPermissionRequest
            else {
                return
            }

            isRequestingNotificationPermission = true
            Task { @MainActor in
                let isGranted: Bool
                do {
                    isGranted = try await UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.provisional])
                } catch {
                    isRequestingNotificationPermission = false
                    suspendAutomaticNotificationPermissionChecks()
                    notificationLogger.error(
                        "Milestone notification authorization failed: \(error.localizedDescription, privacy: .public)"
                    )
                    return
                }
                isRequestingNotificationPermission = false
                notificationLogger.info(
                    "Milestone notification authorization result: \(isGranted, privacy: .public)"
                )
                if isGranted {
                    cachedNotificationPermissionState = .authorized
                    resetNotificationPermissionBackoff()
                } else {
                    suspendAutomaticNotificationPermissionChecks()
                    return
                }

                Self.addNotification(identifier: identifier, body: body)
            }
        case .skip:
            suspendAutomaticNotificationPermissionChecks()
            return
        }
    }

    private var shouldCheckNotificationPermission: Bool {
        guard let notificationPermissionRetryDate else {
            return true
        }

        return Date() >= notificationPermissionRetryDate
    }

    private func suspendAutomaticNotificationPermissionChecks() {
        didFailAutomaticNotificationPermissionRequest = true
        notificationPermissionRetryDate = Date().addingTimeInterval(notificationPermissionRetryInterval)
    }

    private static func addNotification(identifier: String, body: String) {
        notificationLogger.info(
            "Adding milestone notification \(identifier, privacy: .public) body: \(body, privacy: .public)"
        )
        let content = UNMutableNotificationContent()
        content.title = "얼마범?"
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                notificationLogger.error(
                    "Adding milestone notification failed: \(error.localizedDescription, privacy: .public)"
                )
                return
            }

            notificationLogger.info("Milestone notification add succeeded")
        }
    }

    private static func lastMilestoneAmount(input: PayInput, currentTime: Date) -> Double {
        floor(PayCalculator.earned(input: input, currentTime: currentTime) / input.alertUnit)
            * input.alertUnit
    }

    nonisolated private static func permissionState(
        from authorizationStatus: UNAuthorizationStatus
    ) -> MilestoneNotificationPermissionState {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            .authorized
        case .notDetermined:
            .notDetermined
        case .denied:
            .denied
        @unknown default:
            .denied
        }
    }
}
