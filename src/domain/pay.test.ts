import { describe, expect, it } from "vitest"
import { calculateWonPerSecond, formatKoreanCurrencyUnit } from "./pay"

describe("pay domain", () => {
  it("formats Korean readable currency units", () => {
    expect(formatKoreanCurrencyUnit(1000)).toBe("1천원")
    expect(formatKoreanCurrencyUnit(100000)).toBe("10만원")
    expect(formatKoreanCurrencyUnit(5000000)).toBe("5백만원")
  })

  it("spreads monthly salary across every calendar second in the month", () => {
    const currentTime = new Date(2026, 5, 11, 0, 0, 0).getTime()

    expect(
      calculateWonPerSecond(
        {
          monthlySalary: 3000000,
          monthlyHours: 160,
          alertUnit: 1000,
        },
        currentTime,
      ),
    ).toBeCloseTo(1.1574, 4)
  })
})
