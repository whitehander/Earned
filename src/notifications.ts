type RandomSource = () => number

const encouragementMessages = [
  "힘내세요!",
  "고생하셨습니다.",
  "오늘도 차곡차곡 쌓이고 있어요.",
  "조금만 더 가면 또 쌓입니다.",
  "이미 잘하고 있습니다.",
] as const

export function createMilestoneNotificationMessage(
  amountLabel: string,
  randomSource: RandomSource = Math.random,
): string {
  return `${amountLabel} 벌었습니다. ${selectEncouragementMessage(randomSource)}`
}

export function requestBrowserNotification(message: string): void {
  if (!("Notification" in window) || Notification.permission !== "granted") {
    return
  }

  new Notification("얼마범", {
    body: message,
    tag: "earned-milestone",
  })
}

function selectEncouragementMessage(randomSource: RandomSource): string {
  const slot = Math.floor(Math.max(0, Math.min(0.999_999, randomSource())) * 5)

  switch (slot) {
    case 0:
      return encouragementMessages[0]
    case 1:
      return encouragementMessages[1]
    case 2:
      return encouragementMessages[2]
    case 3:
      return encouragementMessages[3]
    default:
      return encouragementMessages[4]
  }
}
