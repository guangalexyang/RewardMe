import Foundation
import SwiftData

@Model
final class Redemption {
    var timestamp: Date
    var note: String?
    var pointsDeducted: Int   // 0 if rule has no point cost
    var child: Child?
    var rule: Rule?

    init(timestamp: Date = .now, note: String? = nil, pointsDeducted: Int = 0, child: Child? = nil, rule: Rule? = nil) {
        self.timestamp = timestamp
        self.note = note
        self.pointsDeducted = pointsDeducted
        self.child = child
        self.rule = rule
    }
}
