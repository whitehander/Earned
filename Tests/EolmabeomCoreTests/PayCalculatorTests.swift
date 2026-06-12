import XCTest
import Foundation
@testable import EolmabeomCore

final class PayCalculatorTests: XCTestCase {
    func testWonPerSecondSpreadsMonthlySalaryAcrossEveryCalendarSecond() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        let currentTime = date(
            year: 2026,
            month: 6,
            day: 11,
            calendar: calendar
        )

        let result = PayCalculator.wonPerSecond(
            input: .defaultValue,
            currentTime: currentTime,
            calendar: calendar
        )

        XCTAssertEqual(result, 1.1574, accuracy: 0.0001)
    }

    func testEarnedAmountKeepsIncreasingAsTimeAdvances() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        let start = date(year: 2026, month: 6, day: 11, calendar: calendar)
        let later = start.addingTimeInterval(0.125)

        let startAmount = PayCalculator.earned(
            input: .defaultValue,
            currentTime: start,
            calendar: calendar
        )
        let laterAmount = PayCalculator.earned(
            input: .defaultValue,
            currentTime: later,
            calendar: calendar
        )

        XCTAssertGreaterThan(laterAmount, startAmount)
    }

    func testFormatsWonLabelsForWindowAndMenuBar() {
        XCTAssertEqual(PayCalculator.formatWon(2_000_000), "2,000,000.00원")
        XCTAssertEqual(PayCalculator.formatWholeWon(2_000_000.78), "2,000,000원")
    }

    func testFormatsKoreanReadableCurrencyUnits() {
        XCTAssertEqual(PayCalculator.formatKoreanCurrencyUnit(1_000), "1천원")
        XCTAssertEqual(PayCalculator.formatKoreanCurrencyUnit(100_000), "10만원")
        XCTAssertEqual(PayCalculator.formatKoreanCurrencyUnit(5_000_000), "5백만원")
    }

    func testParsesInvalidPayInputWithUserFacingMessage() {
        let result = PayCalculator.parsePayInput(
            monthlySalary: 0,
            monthlyHours: 160,
            alertUnit: 1_000
        )

        XCTAssertEqual(result, .invalid(PayCalculator.invalidInputMessage))
    }

    private func date(
        year: Int,
        month: Int,
        day: Int,
        calendar: Calendar
    ) -> Date {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }
}
