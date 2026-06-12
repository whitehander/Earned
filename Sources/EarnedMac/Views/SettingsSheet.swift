import AppKit
import SwiftUI
import UserNotifications
import EarnedCore

struct SettingsSheet: View {
    @ObservedObject var ticker: EarningsTicker
    @Environment(\.dismiss) private var dismiss
    let onClose: () -> Void

    @State private var monthlySalary: String
    @State private var monthlyHours: String
    @State private var alertUnit: String
    @State private var error = ""
    @State private var notificationAction: MilestoneNotificationSettingsAction = .disabled(
        label: "알림 상태 확인 중"
    )

    init(ticker: EarningsTicker, onClose: @escaping () -> Void = {}) {
        self.ticker = ticker
        self.onClose = onClose
        _monthlySalary = State(initialValue: PayCalculator.formatCurrencyInput(
            String(Int(ticker.input.monthlySalary))
        ))
        _monthlyHours = State(initialValue: String(format: "%.0f", ticker.input.monthlyHours))
        _alertUnit = State(initialValue: PayCalculator.formatCurrencyInput(
            String(Int(ticker.input.alertUnit))
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("설정")
                    .font(.title3.weight(.semibold))

                Spacer()

                Button {
                    close()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("설정 닫기")
            }

            Form {
                Section("급여 설정") {
                    TextField("월급 (실수령액)", text: $monthlySalary)
                        .onChange(of: monthlySalary) { _, value in
                            updateMonthlySalary(value)
                        }

                    Text(readableSalary)
                        .foregroundStyle(.secondary)

                    TextField("월 근무시간", text: $monthlyHours)
                        .onChange(of: monthlyHours) { _, _ in
                            applyCurrentInput()
                        }
                }

                Section("알림 설정") {
                    TextField("금액 알림 단위", text: $alertUnit)
                        .onChange(of: alertUnit) { _, value in
                            updateAlertUnit(value)
                        }

                    Button(notificationButtonLabel) {
                        performNotificationAction()
                    }
                    .disabled(isNotificationButtonDisabled)
                }
            }

            if !error.isEmpty {
                Text(error)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .accessibilityAddTraits(.isStaticText)
            }

            HStack {
                Spacer()

                Button("완료") {
                    close()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 420)
        .onAppear(perform: refreshNotificationStatus)
    }

    private var readableSalary: String {
        PayCalculator.formatKoreanCurrencyUnit(PayCalculator.parseCurrencyInput(monthlySalary))
    }

    private var notificationButtonLabel: String {
        switch notificationAction {
        case .disabled(let label),
             .requestPermission(let label),
             .openSystemSettings(let label):
            label
        }
    }

    private var isNotificationButtonDisabled: Bool {
        if case .disabled = notificationAction {
            return true
        }

        return false
    }

    private func updateMonthlySalary(_ value: String) {
        let formatted = PayCalculator.formatCurrencyInput(value)
        if monthlySalary != formatted {
            monthlySalary = formatted
            return
        }

        applyCurrentInput()
    }

    private func updateAlertUnit(_ value: String) {
        let formatted = PayCalculator.formatCurrencyInput(value)
        if alertUnit != formatted {
            alertUnit = formatted
            return
        }

        applyCurrentInput()
    }

    private func applyCurrentInput() {
        let parsed = PayCalculator.parsePayInput(
            monthlySalary: PayCalculator.parseCurrencyInput(monthlySalary),
            monthlyHours: Double(monthlyHours) ?? Double.nan,
            alertUnit: PayCalculator.parseCurrencyInput(alertUnit)
        )

        switch parsed {
        case .valid(let input):
            ticker.apply(input)
            error = ""
        case .invalid(let message):
            error = message
        }
    }

    private func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                let state = Self.permissionState(from: settings.authorizationStatus)
                notificationAction = MilestoneNotificationPermissionPolicy.settingsAction(for: state)
                ticker.updateNotificationPermissionState(state)
            }
        }
    }

    private func performNotificationAction() {
        switch notificationAction {
        case .disabled:
            break
        case .requestPermission:
            requestNotificationPermission()
        case .openSystemSettings:
            openNotificationSettings()
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
            refreshNotificationStatus()
        }
    }

    private func openNotificationSettings() {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.whitehander.earned.mac"
        let urlString = "x-apple.systempreferences:com.apple.Notifications-Settings.extension?\(bundleIdentifier)"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
        refreshNotificationStatus()
    }

    private func close() {
        onClose()
        dismiss()
    }

    private static func permissionState(
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
