export type NotificationPermissionStatus = NotificationPermission | "unsupported"

type NotificationSettingsModalProps = {
  readonly monthlySalary: string
  readonly alertUnit: string
  readonly readableSalary: string
  readonly error: string
  readonly notificationPermission: NotificationPermissionStatus
  readonly onMonthlySalaryChange: (value: string) => void
  readonly onAlertUnitChange: (value: string) => void
  readonly onClose: () => void
  readonly onEnableNotifications: () => Promise<void>
}

export function SettingsModal({
  monthlySalary,
  alertUnit,
  readableSalary,
  error,
  notificationPermission,
  onMonthlySalaryChange,
  onAlertUnitChange,
  onClose,
  onEnableNotifications,
}: NotificationSettingsModalProps) {
  return (
    <div className="modal-backdrop">
      <section
        className="notification-modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="settings-title"
      >
        <header className="modal-header">
          <h2 id="settings-title">설정</h2>
          <button
            className="modal-close-button"
            type="button"
            onClick={onClose}
            aria-label="설정 닫기"
          >
            ×
          </button>
        </header>

        <form className="settings-form" onSubmit={(event) => event.preventDefault()}>
          <section className="settings-section" aria-labelledby="pay-settings-title">
            <h3 id="pay-settings-title">급여 설정</h3>
            <label>
              월급 (실수령액)
              <input
                inputMode="numeric"
                type="text"
                value={monthlySalary}
                onChange={(event) => onMonthlySalaryChange(event.target.value)}
              />
            </label>

            <fieldset className="unit-hints" aria-label="월급 한글 표기">
              <span>{readableSalary}</span>
            </fieldset>
          </section>

          <section className="settings-section" aria-labelledby="alert-settings-title">
            <h3 id="alert-settings-title">알림 설정</h3>
            <label>
              금액 알림 단위
              <input
                inputMode="numeric"
                type="text"
                value={alertUnit}
                onChange={(event) => onAlertUnitChange(event.target.value)}
              />
            </label>
            <button
              className="secondary-button"
              type="button"
              disabled={
                notificationPermission === "granted" || notificationPermission === "unsupported"
              }
              onClick={() => {
                void onEnableNotifications()
              }}
            >
              {getNotificationButtonLabel(notificationPermission)}
            </button>
          </section>
        </form>

        {error.length > 0 ? (
          <p className="form-error" role="alert">
            {error}
          </p>
        ) : null}

        <div className="modal-actions">
          <button className="primary-button" type="button" onClick={onClose}>
            완료
          </button>
        </div>
      </section>
    </div>
  )
}

function getNotificationButtonLabel(permission: NotificationPermissionStatus): string {
  switch (permission) {
    case "granted":
      return "알림 켜져있음"
    case "unsupported":
      return "알림 미지원"
    case "denied":
      return "알림 권한 거부됨"
    case "default":
      return "브라우저 알림 켜기"
  }
}
