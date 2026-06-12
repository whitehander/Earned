import Foundation

public struct PayInput: Equatable, Sendable {
    public let monthlySalary: Double
    public let monthlyHours: Double
    public let alertUnit: Double

    public init(monthlySalary: Double, monthlyHours: Double, alertUnit: Double) {
        self.monthlySalary = monthlySalary
        self.monthlyHours = monthlyHours
        self.alertUnit = alertUnit
    }

    public static let defaultValue = PayInput(
        monthlySalary: 3_000_000,
        monthlyHours: 160,
        alertUnit: 1_000
    )
}

public enum PayCalculator {
    public static func wonPerSecond(
        input: PayInput,
        currentTime: Date,
        calendar: Calendar = .current
    ) -> Double {
        let daysInMonth = Double(Self.daysInMonth(for: currentTime, calendar: calendar))
        let averageWorkHoursPerDay = input.monthlyHours / daysInMonth
        let hourlyPay = input.monthlySalary / input.monthlyHours
        let averageDailyPay = hourlyPay * averageWorkHoursPerDay
        return averageDailyPay / 24 / 3_600
    }

    public static func monthElapsedSeconds(
        currentTime: Date,
        calendar: Calendar = .current
    ) -> Double {
        let components = calendar.dateComponents([.year, .month], from: currentTime)
        guard let monthStart = calendar.date(from: components) else {
            return 0
        }

        return max(0, currentTime.timeIntervalSince(monthStart))
    }

    public static func earned(
        input: PayInput,
        currentTime: Date,
        calendar: Calendar = .current
    ) -> Double {
        monthElapsedSeconds(currentTime: currentTime, calendar: calendar)
            * wonPerSecond(input: input, currentTime: currentTime, calendar: calendar)
    }

    public static func formatWon(_ value: Double) -> String {
        "\(format(value, minimumFractionDigits: 2, maximumFractionDigits: 2))원"
    }

    public static func formatWholeWon(_ value: Double) -> String {
        "\(format(floor(value), minimumFractionDigits: 0, maximumFractionDigits: 0))원"
    }

    private static func daysInMonth(for currentTime: Date, calendar: Calendar) -> Int {
        calendar.range(of: .day, in: .month, for: currentTime)?.count ?? 30
    }

    private static func format(
        _ value: Double,
        minimumFractionDigits: Int,
        maximumFractionDigits: Int
    ) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
}
