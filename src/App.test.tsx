import { act, fireEvent, render, screen } from "@testing-library/react"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import { App } from "./App"

describe("App", () => {
  beforeEach(() => {
    window.localStorage.clear()
    document.documentElement.removeAttribute("data-theme")
    Object.defineProperty(window.navigator, "platform", { value: "MacIntel", configurable: true })
    Object.defineProperty(window.navigator, "userAgent", {
      value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0)",
      configurable: true,
    })
    vi.useFakeTimers()
    vi.setSystemTime(new Date("2026-06-11T00:00:00.000Z"))
  })

  afterEach(() => {
    vi.restoreAllMocks()
    vi.unstubAllGlobals()
    vi.useRealTimers()
    document.documentElement.removeAttribute("data-theme")
    window.localStorage.clear()
  })

  it("calculates earnings as soon as pay inputs change", async () => {
    // Given: 앱이 월 1일부터 오늘까지의 수익을 보여준다.
    vi.setSystemTime(new Date(2026, 5, 11, 0, 0, 0))
    render(<App />)

    // When: 사용자가 설정에서 월급을 바꾼다.
    fireEvent.click(screen.getByRole("button", { name: "설정" }))
    fireEvent.change(screen.getByLabelText("월급 (실수령액)"), { target: { value: "6000000" } })

    // Then: 월 1일부터 오늘까지의 수익만 사용자에게 크게 보인다.
    expect(screen.getByDisplayValue("6,000,000")).toBeVisible()
    expect(screen.getByRole("heading", { name: "지금까지 번 돈" })).toBeVisible()
    expect(screen.getByRole("link", { name: "Mac 다운로드" })).toHaveAttribute(
      "href",
      "https://github.com/whitehander/Earned/releases/latest/download/Earned-macOS.zip",
    )
    expect(screen.getByRole("link", { name: "GitHub 저장소" })).toHaveAttribute(
      "href",
      "https://github.com/whitehander/Earned",
    )
    expect(screen.getByTestId("earned-amount")).toHaveClass("amount-value")
    expect(screen.getByTestId("earned-amount")).toHaveTextContent("2,000,000.00원")
    expect(screen.queryByRole("button", { name: "초당 1.16원" })).not.toBeInTheDocument()
    expect(screen.queryByTestId("rate-amount")).not.toBeInTheDocument()
    expect(screen.queryByText("오늘까지 얼마나 벌었을까?")).not.toBeInTheDocument()
    expect(screen.queryByRole("button", { name: "설정값 저장" })).not.toBeInTheDocument()
    expect(screen.queryByText("초당")).not.toBeInTheDocument()
    expect(screen.queryByText("이번 달 누적 1,000,000.00원")).not.toBeInTheDocument()
    expect(screen.queryByText("이번 달 1일부터 오늘까지")).not.toBeInTheDocument()
    expect(screen.queryByText("광고")).not.toBeInTheDocument()
    expect(screen.queryByText("소액 수익화를 위한 배너 슬롯")).not.toBeInTheDocument()
    expect(screen.queryByRole("button", { name: "근무 시작" })).not.toBeInTheDocument()
    expect(screen.queryByRole("button", { name: "정지" })).not.toBeInTheDocument()
  })

  it("hides the Mac download link on mobile browsers", () => {
    // Given: 모바일 브라우저에서 앱을 연다.
    Object.defineProperty(window.navigator, "platform", { value: "iPhone", configurable: true })
    Object.defineProperty(window.navigator, "userAgent", {
      value: "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) Mobile",
      configurable: true,
    })

    // When: 앱을 렌더링한다.
    render(<App />)

    // Then: Mac 다운로드는 숨기고 저장소 바로가기는 유지한다.
    expect(screen.queryByRole("link", { name: "Mac 다운로드" })).not.toBeInTheDocument()
    expect(screen.getByRole("link", { name: "GitHub 저장소" })).toBeVisible()
  })

  it("refreshes displayed earnings every 125 milliseconds", () => {
    // Given: 월급이 기본값이고 현재 시간이 고정되어 있다.
    vi.setSystemTime(new Date(2026, 5, 11, 0, 0, 0))
    render(<App />)

    // When: 125ms가 지난다.
    act(() => {
      vi.advanceTimersByTime(125)
    })

    // Then: 표시 금액이 갱신된다.
    expect(screen.getByTestId("earned-amount")).toHaveTextContent("1,000,000.14원")
  })

  it("rotates the earned money headline every 3 seconds", () => {
    render(<App />)

    expect(screen.getByTestId("earned-headline")).toHaveTextContent("지금까지 번 돈")

    act(() => {
      vi.advanceTimersByTime(3000)
    })

    expect(screen.getByTestId("earned-headline")).toHaveTextContent("1일부터 지금까지")

    act(() => {
      vi.advanceTimersByTime(3000)
    })

    expect(screen.getByTestId("earned-headline")).toHaveTextContent("여태까지 번 돈")
  })

  it("blocks invalid pay inputs", async () => {
    // Given: 필수 입력이 비어 있다.
    render(<App />)

    // When: 사용자가 설정에서 월급 입력을 비운다.
    fireEvent.click(screen.getByRole("button", { name: "설정" }))
    fireEvent.change(screen.getByLabelText("월급 (실수령액)"), { target: { value: "" } })

    // Then: 계산은 시작되지 않고 검증 메시지가 표시된다.
    expect(screen.getByText("월급을 0보다 크게 입력하세요.")).toBeVisible()
    expect(screen.queryByText("저장되었습니다.")).not.toBeInTheDocument()
  })

  it("opens settings from the top icon", () => {
    // Given: 앱이 렌더링되어 있다.
    render(<App />)

    // When: 사용자가 설정을 연다.
    expect(screen.queryByLabelText("월급 (실수령액)")).not.toBeInTheDocument()
    expect(screen.queryByLabelText("금액 알림 단위")).not.toBeInTheDocument()
    fireEvent.click(screen.getByRole("button", { name: "설정" }))

    // Then: 월급과 알림 단위 입력은 모달 안에서만 보인다.
    expect(screen.getByRole("dialog", { name: "설정" })).toBeVisible()
    expect(screen.getByRole("heading", { name: "급여 설정" })).toBeVisible()
    expect(screen.getByRole("heading", { name: "알림 설정" })).toBeVisible()
    expect(screen.getByLabelText("월급 (실수령액)")).toHaveValue("3,000,000")
    expect(screen.queryByLabelText("월 근무시간")).not.toBeInTheDocument()
    expect(screen.getByLabelText("금액 알림 단위")).toHaveValue("1,000")
  })

  it("shows enabled notification state when browser permission is granted", () => {
    // Given: 브라우저 알림 권한이 이미 허용되어 있다.
    const notification = vi.fn()
    vi.stubGlobal("Notification", Object.assign(notification, { permission: "granted" }))
    render(<App />)

    // When: 사용자가 설정을 연다.
    fireEvent.click(screen.getByRole("button", { name: "설정" }))

    // Then: 알림 버튼은 켜진 상태로 표시된다.
    expect(screen.getByRole("button", { name: "알림 켜져있음" })).toBeDisabled()
  })

  it("shows Korean readable unit for the salary amount", () => {
    // Given: 앱이 렌더링되어 있다.
    render(<App />)

    // When: 설정에서 월급 금액을 바꾼다.
    fireEvent.click(screen.getByRole("button", { name: "설정" }))
    fireEvent.change(screen.getByLabelText("월급 (실수령액)"), { target: { value: "5000000" } })

    // Then: 입력 금액을 읽기 쉬운 한글 단위로 추가 표시한다.
    expect(screen.getByText("5백만원")).toBeVisible()
  })

  it("reduces earned amount text size when the amount gets long", () => {
    // Given: 매우 큰 월급이 입력되어 있다.
    vi.setSystemTime(new Date(2026, 5, 11, 0, 0, 0))
    render(<App />)

    // When: 사용자가 설정에서 큰 금액을 입력한다.
    fireEvent.click(screen.getByRole("button", { name: "설정" }))
    fireEvent.change(screen.getByLabelText("월급 (실수령액)"), {
      target: { value: "999999999999" },
    })

    // Then: 길어진 금액 텍스트는 더 작은 크기 규칙을 가진다.
    expect(screen.getByTestId("earned-amount").querySelector("span")).toHaveStyle({
      fontSize: "max(36px, min(9vh, 6.2vw))",
    })
  })

  it("toggles and stores dark mode", () => {
    // Given: 앱이 라이트 모드로 렌더링되어 있다.
    render(<App />)

    // When: 사용자가 다크 모드 토글을 누른다.
    fireEvent.click(screen.getByRole("button", { name: "다크 모드로 전환" }))

    // Then: 다크 모드가 적용되고 다시 라이트 모드로 돌아갈 수 있다.
    expect(document.documentElement.getAttribute("data-theme")).toBe("dark")
    expect(window.localStorage.getItem("earned-theme")).toBe("dark")
    expect(screen.getByRole("button", { name: "라이트 모드로 전환" })).toBeVisible()
  })

  it("loads stored dark mode", () => {
    // Given: 사용자가 이전에 다크 모드를 저장했다.
    window.localStorage.setItem("earned-theme", "dark")

    // When: 앱이 다시 렌더링된다.
    render(<App />)

    // Then: 저장된 다크 모드가 바로 적용된다.
    expect(document.documentElement.getAttribute("data-theme")).toBe("dark")
    expect(screen.getByRole("button", { name: "라이트 모드로 전환" })).toBeVisible()
  })

  it("sends milestone alert without rendering alert panels", async () => {
    // Given: 1초마다 1원씩 벌고 1원 단위 알림을 켠다.
    vi.setSystemTime(new Date(2026, 5, 1, 0, 0, 0))
    vi.spyOn(Math, "random").mockReturnValue(0)
    const notification = vi.fn()
    vi.stubGlobal("Notification", Object.assign(notification, { permission: "granted" }))
    render(<App />)

    fireEvent.click(screen.getByRole("button", { name: "설정" }))
    fireEvent.change(screen.getByLabelText("월급 (실수령액)"), { target: { value: "2592000" } })
    fireEvent.change(screen.getByLabelText("금액 알림 단위"), { target: { value: "1" } })

    // When: 1초가 지난다.
    act(() => {
      vi.advanceTimersByTime(1000)
    })

    // Then: 화면 패널 없이 브라우저 알림만 발송된다.
    expect(notification).toHaveBeenCalledWith("얼마범", {
      body: "1원 벌었습니다. 힘내세요!",
      tag: "earned-milestone",
    })
    expect(screen.queryByText("알림 기록")).not.toBeInTheDocument()
    expect(screen.queryByText("다음 금액 알림")).not.toBeInTheDocument()
  })
})
