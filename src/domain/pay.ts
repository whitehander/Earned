export type PayInput = {
  readonly monthlySalary: number
  readonly alertUnit: number
}

export type PayInputResult =
  | { readonly kind: "valid"; readonly value: PayInput }
  | { readonly kind: "invalid"; readonly message: string }

const invalidInputMessage = "월급을 0보다 크게 입력하세요."

export function parseCurrencyInput(value: string): number {
  const normalized = value.replaceAll(",", "").trim()
  return normalized.length === 0 ? Number.NaN : Number(normalized)
}

export function formatCurrencyInput(value: string): string {
  const digits = value.replace(/\D/g, "")
  if (digits.length === 0) {
    return ""
  }

  return Number(digits).toLocaleString("ko-KR")
}

export function parsePayInput(monthlySalary: number, alertUnit: number): PayInputResult {
  if (!Number.isFinite(monthlySalary)) {
    return { kind: "invalid", message: invalidInputMessage }
  }

  if (monthlySalary <= 0) {
    return { kind: "invalid", message: invalidInputMessage }
  }

  return {
    kind: "valid",
    value: {
      monthlySalary,
      alertUnit: Number.isFinite(alertUnit) && alertUnit > 0 ? alertUnit : 1000,
    },
  }
}

export function calculateWonPerSecond(input: PayInput, currentTime: number): number {
  const daysInMonth = getDaysInMonth(currentTime)
  return input.monthlySalary / daysInMonth / 24 / 3600
}

export function calculateMonthElapsedSeconds(currentTime: number): number {
  const now = new Date(currentTime)
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1).getTime()
  return Math.max(0, (currentTime - monthStart) / 1000)
}

export function formatKoreanCurrencyUnit(value: number): string {
  if (!Number.isFinite(value) || value <= 0) {
    return ""
  }

  if (value >= 100000000 && value % 100000000 === 0) {
    return `${value / 100000000}억원`
  }

  if (value >= 10000000 && value % 10000000 === 0) {
    return `${value / 10000000}천만원`
  }

  if (value >= 1000000 && value % 1000000 === 0) {
    return `${value / 1000000}백만원`
  }

  if (value >= 10000 && value % 10000 === 0) {
    return `${value / 10000}만원`
  }

  if (value >= 1000 && value % 1000 === 0) {
    return `${value / 1000}천원`
  }

  return formatWholeWon(value)
}

export function formatWon(value: number): string {
  return `${value.toLocaleString("ko-KR", {
    maximumFractionDigits: 2,
    minimumFractionDigits: 2,
  })}원`
}

export function formatWholeWon(value: number): string {
  return `${Math.floor(value).toLocaleString("ko-KR")}원`
}

function getDaysInMonth(currentTime: number): number {
  const now = new Date(currentTime)
  return new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate()
}
