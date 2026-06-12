import { afterEach, describe, expect, it, vi } from "vitest"
import { createMilestoneNotificationMessage, requestBrowserNotification } from "./notifications"

describe("notifications", () => {
  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it("formats milestone messages as earned money with deterministic encouragement", () => {
    // Given: a milestone amount and the first encouragement slot.
    const firstEncouragement = () => 0

    // When: the milestone notification message is created.
    const message = createMilestoneNotificationMessage("1,000원", firstEncouragement)

    // Then: the message says the user earned money and includes encouragement.
    expect(message).toBe("1,000원 벌었습니다. 힘내세요!")
  })

  it("uses different encouragement copy from the random slot", () => {
    // Given: a milestone amount and another encouragement slot.
    const laterEncouragement = () => 0.35

    // When: the milestone notification message is created.
    const message = createMilestoneNotificationMessage("2,000원", laterEncouragement)

    // Then: a different encouragement line can be selected.
    expect(message).toBe("2,000원 벌었습니다. 고생하셨습니다.")
  })

  it("sends the formatted message to browser notifications", () => {
    // Given: browser notifications are available and granted.
    const notification = vi.fn()
    vi.stubGlobal("Notification", Object.assign(notification, { permission: "granted" }))

    // When: the browser notification is requested.
    requestBrowserNotification("3,000원 벌었습니다. 오늘도 차곡차곡 쌓이고 있어요.")

    // Then: the exact formatted message is used as the body.
    expect(notification).toHaveBeenCalledWith("얼마범", {
      body: "3,000원 벌었습니다. 오늘도 차곡차곡 쌓이고 있어요.",
      tag: "earned-milestone",
    })
  })
})
