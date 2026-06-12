import { describe, expect, it } from "vitest"
import { earnedHeadlineIntervalMs, earnedHeadlines, getEarnedHeadline } from "./headlines"

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
})
