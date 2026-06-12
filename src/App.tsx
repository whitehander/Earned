import { useEffect, useMemo, useState } from "react"
import { earnedHeadlineIntervalMs, earnedHeadlines, getEarnedHeadline } from "./domain/headlines"
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
  monthlyHours: 160,
  alertUnit: 1000,
}

const settingsStorageKey = "earned-settings"
const themeStorageKey = "earned-theme"

export function App() {
  const [monthlySalary, setMonthlySalary] = useState(
    formatCurrencyInput(String(defaultPayInput.monthlySalary)),
  )
  const [monthlyHours, setMonthlyHours] = useState(String(defaultPayInput.monthlyHours))
  const [alertUnit, setAlertUnit] = useState(formatCurrencyInput(String(defaultPayInput.alertUnit)))
  const [activeInput, setActiveInput] = useState<PayInput>(defaultPayInput)
  const [currentTime, setCurrentTime] = useState(Date.now())
  const [error, setError] = useState("")
  const [lastMilestoneAmount, setLastMilestoneAmount] = useState(0)
  const [theme, setTheme] = useState<Theme>(readStoredTheme)
  const [isSettingsOpen, setIsSettingsOpen] = useState(false)
  const [headlineIndex, setHeadlineIndex] = useState(0)
  const [notificationPermission, setNotificationPermission] =
    useState<NotificationPermissionStatus>(readNotificationPermission)

  const wonPerSecond = useMemo(
    () => calculateWonPerSecond(activeInput, currentTime),
    [activeInput, currentTime],
  )
  const elapsedSeconds = calculateMonthElapsedSeconds(currentTime)
  const earned = elapsedSeconds * wonPerSecond
  const earnedLabel = formatWon(earned)
  const earnedHeadline = getEarnedHeadline(headlineIndex)
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
    const intervalId = window.setInterval(() => {
      setHeadlineIndex((currentIndex) => (currentIndex + 1) % earnedHeadlines.length)
    }, earnedHeadlineIntervalMs)

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

  function applyPayInput(
    nextMonthlySalary: string,
    nextMonthlyHours: string,
    nextAlertUnit: string,
  ): void {
    const parsed = parsePayInput(
      parseCurrencyInput(nextMonthlySalary),
      Number(nextMonthlyHours),
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
    applyPayInput(nextMonthlySalary, monthlyHours, alertUnit)
  }

  function updateMonthlyHours(value: string): void {
    setMonthlyHours(value)
    applyPayInput(monthlySalary, value, alertUnit)
  }

  function updateAlertUnit(value: string): void {
    const nextAlertUnit = formatCurrencyInput(value)
    setAlertUnit(nextAlertUnit)
    applyPayInput(monthlySalary, monthlyHours, nextAlertUnit)
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
            monthlyHours={monthlyHours}
            alertUnit={alertUnit}
            readableSalary={readableSalary}
            error={error}
            notificationPermission={notificationPermission}
            onMonthlySalaryChange={updateMonthlySalary}
            onMonthlyHoursChange={updateMonthlyHours}
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
