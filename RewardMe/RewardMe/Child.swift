import Foundation
import SwiftData

@Model
final class Child {
    var name: String
    var emoji: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var events: [PointEvent] = []

    @Relationship(deleteRule: .cascade)
    var redemptions: [Redemption] = []

    init(name: String, emoji: String = "⭐️") {
        self.name = name
        self.emoji = emoji
        self.createdAt = .now
    }

    var balance: Int {
        events.reduce(0) { $0 + $1.delta }
    }

    func earnedInPeriod(_ period: ThresholdPeriod) -> Int {
        let start = period.startDate
        return events
            .filter { $0.delta > 0 && $0.timestamp >= start }
            .reduce(0) { $0 + $1.delta }
    }
}
