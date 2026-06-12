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

public enum PayInputResult: Equatable, Sendable {
    case valid(PayInput)
    case invalid(String)
}

public enum PayCalculator {
    public static let invalidInputMessage = "월급과 월 근무시간을 0보다 크게 입력하세요."

    public static func parseCurrencyInput(_ value: String) -> Double {
        let normalized = value.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespaces)
        return normalized.isEmpty ? Double.nan : Double(normalized) ?? Double.nan
    }

    public static func formatCurrencyInput(_ value: String) -> String {
        let digits = value.filter(\.isNumber)
        guard let number = Double(digits), !digits.isEmpty else {
            return ""
        }

        return format(number, minimumFractionDigits: 0, maximumFractionDigits: 0)
    }

    public static func parsePayInput(
        monthlySalary: Double,
        monthlyHours: Double,
        alertUnit: Double
    ) -> PayInputResult {
        guard monthlySalary.isFinite, monthlyHours.isFinite, monthlySalary > 0, monthlyHours > 0 else {
            return .invalid(invalidInputMessage)
        }

        let normalizedAlertUnit = alertUnit.isFinite && alertUnit > 0 ? alertUnit : 1_000
        return .valid(PayInput(
            monthlySalary: monthlySalary,
            monthlyHours: monthlyHours,
            alertUnit: normalizedAlertUnit
        ))
    }

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

    public static func formatKoreanCurrencyUnit(_ value: Double) -> String {
        guard value.isFinite, value > 0 else {
            return ""
        }

        if value >= 100_000_000, value.truncatingRemainder(dividingBy: 100_000_000) == 0 {
            return "\(Int(value / 100_000_000))억원"
        }

        if value >= 10_000_000, value.truncatingRemainder(dividingBy: 10_000_000) == 0 {
            return "\(Int(value / 10_000_000))천만원"
        }

        if value >= 1_000_000, value.truncatingRemainder(dividingBy: 1_000_000) == 0 {
            return "\(Int(value / 1_000_000))백만원"
        }

        if value >= 10_000, value.truncatingRemainder(dividingBy: 10_000) == 0 {
            return "\(Int(value / 10_000))만원"
        }

        if value >= 1_000, value.truncatingRemainder(dividingBy: 1_000) == 0 {
            return "\(Int(value / 1_000))천원"
        }

        return formatWholeWon(value)
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
