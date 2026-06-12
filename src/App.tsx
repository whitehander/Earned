import { useEffect, useMemo, useState } from "react"
import { getEarnedHeadlineAt } from "./domain/headlines"
import {
  calculateMonthElapsedSeconds,
  calculateWonPerSecond,
  formatCurrencyInput,
  formatKoreanCurrencyUnit,
  formatWholeWon,
  formatWon,
  type PayInput,
  parseCurrencyInput,
  parsePayInput,
} from "./domain/pay"
import { type NotificationPermissionStatus, SettingsModal } from "./NotificationSettingsModal"
import { createMilestoneNotificationMessage, requestBrowserNotification } from "./notifications"

type Theme = "light" | "dark"

const defaultPayInput: PayInput = {
  monthlySalary: 3000000,
  alertUnit: 1000,
}

const settingsStorageKey = "earned-settings"
const themeStorageKey = "earned-theme"
const macDownloadUrl =
  "https://github.com/whitehander/Earned/releases/latest/download/Earned-macOS.zip"
const githubUrl = "https://github.com/whitehander/Earned"

export function App() {
  const showMacDownload = isMacDesktopPlatform()
  const [monthlySalary, setMonthlySalary] = useState(
    formatCurrencyInput(String(defaultPayInput.monthlySalary)),
  )
  const [alertUnit, setAlertUnit] = useState(formatCurrencyInput(String(defaultPayInput.alertUnit)))
  const [activeInput, setActiveInput] = useState<PayInput>(defaultPayInput)
  const [currentTime, setCurrentTime] = useState(Date.now())
  const [error, setError] = useState("")
  const [lastMilestoneAmount, setLastMilestoneAmount] = useState(0)
  const [theme, setTheme] = useState<Theme>(readStoredTheme)
  const [isSettingsOpen, setIsSettingsOpen] = useState(false)
  const [headlineStartTime] = useState(() => Date.now())
  const [notificationPermission, setNotificationPermission] =
    useState<NotificationPermissionStatus>(readNotificationPermission)

  const wonPerSecond = useMemo(
    () => calculateWonPerSecond(activeInput, currentTime),
    [activeInput, currentTime],
  )
  const elapsedSeconds = calculateMonthElapsedSeconds(currentTime)
  const earned = elapsedSeconds * wonPerSecond
  const earnedLabel = formatWon(earned)
  const earnedHeadline = getEarnedHeadlineAt(currentTime, headlineStartTime)
  const readableSalary = formatKoreanCurrencyUnit(parseCurrencyInput(monthlySalary))

  useEffect(() => {
    const intervalId = window.setInterval(() => {
      setCurrentTime(Date.now())
    }, 125)

    return () => {
      window.clearInterval(intervalId)
    }
  }, [])

  useEffect(() => {
    document.documentElement.setAttribute("data-theme", theme)
    window.localStorage.setItem(themeStorageKey, theme)
  }, [theme])

  useEffect(() => {
    if (earned < activeInput.alertUnit) {
      return
    }

    const reachedAmount = Math.floor(earned / activeInput.alertUnit) * activeInput.alertUnit
    if (reachedAmount <= lastMilestoneAmount) {
      return
    }

    const label = createMilestoneNotificationMessage(formatWholeWon(reachedAmount))
    setLastMilestoneAmount(reachedAmount)
    requestBrowserNotification(label)
  }, [activeInput.alertUnit, earned, lastMilestoneAmount])

  function applyPayInput(nextMonthlySalary: string, nextAlertUnit: string): void {
    const parsed = parsePayInput(
      parseCurrencyInput(nextMonthlySalary),
      parseCurrencyInput(nextAlertUnit),
    )

    switch (parsed.kind) {
      case "invalid":
        setError(parsed.message)
        return
      case "valid": {
        const now = Date.now()
        setActiveInput(parsed.value)
        setError("")
        setCurrentTime(now)
        setLastMilestoneAmount(calculateLastMilestoneAmount(parsed.value, now))
        window.localStorage.setItem(settingsStorageKey, JSON.stringify(parsed.value))
        return
      }
    }
  }

  function updateMonthlySalary(value: string): void {
    const nextMonthlySalary = formatCurrencyInput(value)
    setMonthlySalary(nextMonthlySalary)
    applyPayInput(nextMonthlySalary, alertUnit)
  }

  function updateAlertUnit(value: string): void {
    const nextAlertUnit = formatCurrencyInput(value)
    setAlertUnit(nextAlertUnit)
    applyPayInput(monthlySalary, nextAlertUnit)
  }

  function toggleTheme(): void {
    setTheme((currentTheme) => (currentTheme === "light" ? "dark" : "light"))
  }

  async function enableNotifications(): Promise<void> {
    if (!("Notification" in window)) {
      setNotificationPermission("unsupported")
      setError("이 브라우저는 알림을 지원하지 않습니다.")
      return
    }

    if (Notification.permission === "granted") {
      setNotificationPermission("granted")
      setError("")
      return
    }

    const permission = await Notification.requestPermission()
    setNotificationPermission(permission)
    if (permission !== "granted") {
      setError("알림 권한이 허용되지 않았습니다.")
      return
    }

    setError("")
  }

  return (
    <main className="app-shell">
      <section className="hero-panel" aria-labelledby="app-title">
        <header className="top-bar">
          <div>
            <h1 id="app-title" className="earned-headline" data-testid="earned-headline">
              {earnedHeadline}
            </h1>
          </div>
          <div className="top-actions">
            {showMacDownload ? (
              <a className="download-link" href={macDownloadUrl}>
                Mac 다운로드
              </a>
            ) : null}
            <a
              className="icon-button icon-link"
              href={githubUrl}
              aria-label="GitHub 저장소"
              target="_blank"
              rel="noreferrer"
            >
              <span className="sr-only">GitHub 저장소</span>
              <svg
                aria-hidden="true"
                viewBox="0 0 16 16"
                width="20"
                height="20"
                fill="currentColor"
              >
                <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82A7.65 7.65 0 0 1 8 4.56c.68 0 1.36.09 2 .26 1.53-1.03 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.28.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8Z" />
              </svg>
            </a>
            <button
              className="icon-button"
              type="button"
              onClick={toggleTheme}
              aria-label={theme === "light" ? "다크 모드로 전환" : "라이트 모드로 전환"}
            >
              <span aria-hidden="true">{theme === "light" ? "☾" : "☀"}</span>
            </button>
            <button
              className="icon-button"
              type="button"
              onClick={() => setIsSettingsOpen(true)}
              aria-label="설정"
            >
              <span aria-hidden="true">⚙</span>
            </button>
          </div>
        </header>

        <div className="earnings-display" aria-live="polite">
          <div className="amount-summary">
            <div className="amount-stage">
              <strong className="amount-value" data-testid="earned-amount">
                <span style={{ fontSize: getAmountFontSize(earnedLabel) }}>{earnedLabel}</span>
              </strong>
            </div>
          </div>
        </div>

        {isSettingsOpen ? (
          <SettingsModal
            monthlySalary={monthlySalary}
            alertUnit={alertUnit}
            readableSalary={readableSalary}
            error={error}
            notificationPermission={notificationPermission}
            onMonthlySalaryChange={updateMonthlySalary}
            onAlertUnitChange={updateAlertUnit}
            onClose={() => setIsSettingsOpen(false)}
            onEnableNotifications={enableNotifications}
          />
        ) : null}
      </section>
    </main>
  )
}

function readStoredTheme(): Theme {
  return window.localStorage.getItem(themeStorageKey) === "dark" ? "dark" : "light"
}

function readNotificationPermission(): NotificationPermissionStatus {
  return "Notification" in window ? Notification.permission : "unsupported"
}

function isMacDesktopPlatform(): boolean {
  const platform = navigator.platform.toLowerCase()
  const userAgent = navigator.userAgent.toLowerCase()

  return platform.includes("mac") && !/iphone|ipad|ipod|android|mobile/.test(userAgent)
}

function getAmountFontSize(amountLabel: string): string {
  if (amountLabel.length >= 17) {
    return "max(36px, min(9vh, 6.2vw))"
  }

  if (amountLabel.length >= 15) {
    return "max(44px, min(11vh, 7.4vw))"
  }

  if (amountLabel.length >= 13) {
    return "max(50px, min(14vh, 8.6vw))"
  }

  return "max(86px, min(18vh, 11vw))"
}

function calculateLastMilestoneAmount(input: PayInput, currentTime: number): number {
  return (
    Math.floor(
      (calculateMonthElapsedSeconds(currentTime) * calculateWonPerSecond(input, currentTime)) /
        input.alertUnit,
    ) * input.alertUnit
  )
}
