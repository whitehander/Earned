import { readFile } from "node:fs/promises"
import { join } from "node:path"
import { describe, expect, it } from "vitest"

const rootDir = process.cwd()

describe("PWA assets", () => {
  it("has installable manifest and service worker registration", async () => {
    // Given: PWA 설치에 필요한 공개 파일과 등록 코드가 있어야 한다.
    const manifestPath = join(rootDir, "public", "manifest.webmanifest")
    const swPath = join(rootDir, "public", "sw.js")
    const registrationPath = join(rootDir, "src", "registerServiceWorker.ts")

    // When: 파일을 읽는다.
    const manifest = await readFile(manifestPath, "utf8")
    const serviceWorker = await readFile(swPath, "utf8")
    const registration = await readFile(registrationPath, "utf8")

    // Then: 설치형 PWA로 인식될 핵심 속성이 있다.
    expect(manifest).toContain('"name": "얼마범"')
    expect(manifest).toContain('"display": "standalone"')
    expect(manifest).toContain('"start_url": "/"')
    expect(serviceWorker).toContain("earned-cache")
    expect(registration).toContain("navigator.serviceWorker.register")
  })
})
