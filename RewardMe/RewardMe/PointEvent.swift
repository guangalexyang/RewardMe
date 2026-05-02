import Foundation
import SwiftData

@Model
final class PointEvent {
    var delta: Int        // positive = earned, negative = spent/removed
    var timestamp: Date
    var note: String?
    var child: Child?
    var rule: Rule?

    init(delta: Int, timestamp: Date = .now, note: String? = nil, child: Child? = nil, rule: Rule? = nil) {
        self.delta = delta
        self.timestamp = timestamp
        self.note = note
        self.child = child
        self.rule = rule
    }
}
