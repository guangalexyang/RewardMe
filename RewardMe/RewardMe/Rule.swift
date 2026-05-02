import Foundation
import SwiftData

enum ThresholdPeriod: String, Codable, CaseIterable {
    case daily, weekly, monthly, yearly

    var label: String { rawValue.capitalized }

    var startDate: Date {
        let cal = Calendar.current
        let now = Date.now
        switch self {
        case .daily:
            return cal.startOfDay(for: now)
        case .weekly:
            return cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        case .monthly:
            return cal.date(from: cal.dateComponents([.year, .month], from: now))!
        case .yearly:
            return cal.date(from: cal.dateComponents([.year], from: now))!
        }
    }
}

@Model
final class Rule {
    var name: String
    var desc: String
    var isArchived: Bool

    // nil = redeeming this rule costs no points
    var pointCostPerUnit: Int?
    var unitLabel: String?      // e.g. "dollar", "minute"

    // nil = no threshold required to unlock redemption
    var thresholdAmount: Int?
    var thresholdPeriod: ThresholdPeriod?

    @Relationship var events: [PointEvent] = []
    @Relationship var redemptions: [Redemption] = []

    init(
        name: String,
        desc: String = "",
        pointCostPerUnit: Int? = nil,
        unitLabel: String? = nil,
        thresholdAmount: Int? = nil,
        thresholdPeriod: ThresholdPeriod? = nil
    ) {
        self.name = name
        self.desc = desc
        self.isArchived = false
        self.pointCostPerUnit = pointCostPerUnit
        self.unitLabel = unitLabel
        self.thresholdAmount = thresholdAmount
        self.thresholdPeriod = thresholdPeriod
    }

    var summary: String {
        var parts: [String] = []
        if let cost = pointCostPerUnit {
            parts.append("\(cost) pt/\(unitLabel ?? "unit")")
        }
        if let amount = thresholdAmount, let period = thresholdPeriod {
            parts.append("≥\(amount) pts/\(period.rawValue)")
        }
        return parts.isEmpty ? "No conditions" : parts.joined(separator: " · ")
    }
}
