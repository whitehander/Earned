import { describe, expect, it } from "vitest"
import {
  earnedHeadlineIntervalMs,
  earnedHeadlines,
  getEarnedHeadline,
  getEarnedHeadlineAt,
} from "./headlines"

describe("earned headlines", () => {
  it("contains enough earned-money captions with funny and self-deprecating lines", () => {
    expect(earnedHeadlines.length).toBeGreaterThanOrEqual(11)
    expect(earnedHeadlines).toContain("지금까지 번 돈")
    expect(earnedHeadlines).toContain("1일부터 지금까지")
    expect(earnedHeadlines).toContain("이렇게 개고생해서 받은 돈")
    expect(earnedHeadlines).toContain("개미는 뚠뚠, 통장은 찔끔")
  })

  it("wraps headline indexes", () => {
    expect(getEarnedHeadline(0)).toBe("지금까지 번 돈")
    expect(getEarnedHeadline(earnedHeadlines.length)).toBe("지금까지 번 돈")
    expect(getEarnedHeadline(-1)).toBe(earnedHeadlines.at(-1))
    expect(earnedHeadlineIntervalMs).toBe(3000)
  })

  it("derives the headline from elapsed time", () => {
    const startTime = new Date("2026-06-12T00:00:00.000Z").getTime()

    expect(getEarnedHeadlineAt(startTime, startTime)).toBe("지금까지 번 돈")
    expect(getEarnedHeadlineAt(startTime + 3000, startTime)).toBe("1일부터 지금까지")
    expect(getEarnedHeadlineAt(startTime + 6000, startTime)).toBe("여태까지 번 돈")
  })
})
