import Foundation
import EolmabeomCore

enum PaySettingsStore {
    private static let monthlySalaryKey = "eolmabeom.monthlySalary"
    private static let monthlyHoursKey = "eolmabeom.monthlyHours"
    private static let alertUnitKey = "eolmabeom.alertUnit"

    static func load() -> PayInput {
        let defaults = UserDefaults.standard
        let monthlySalary = defaults.double(forKey: monthlySalaryKey)
        let monthlyHours = defaults.double(forKey: monthlyHoursKey)
        let alertUnit = defaults.double(forKey: alertUnitKey)

        switch PayCalculator.parsePayInput(
            monthlySalary: monthlySalary,
            monthlyHours: monthlyHours,
            alertUnit: alertUnit
        ) {
        case .valid(let input):
            return input
        case .invalid:
            return .defaultValue
        }
    }

    static func save(_ input: PayInput) {
        let defaults = UserDefaults.standard
        defaults.set(input.monthlySalary, forKey: monthlySalaryKey)
        defaults.set(input.monthlyHours, forKey: monthlyHoursKey)
        defaults.set(input.alertUnit, forKey: alertUnitKey)
    }
}
