import SwiftUI
import SwiftData

struct RedeemView: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Rule.name) private var rules: [Rule]

    @State private var selectedRule: Rule?
    @State private var units = 1
    @State private var note = ""

    var activeRules: [Rule] { rules.filter { !$0.isArchived } }

    var thresholdMet: Bool {
        guard let rule = selectedRule,
              let amount = rule.thresholdAmount,
              let period = rule.thresholdPeriod else { return true }
        return child.earnedInPeriod(period) >= amount
    }

    var pointsToDeduct: Int {
        guard let rule = selectedRule, let cost = rule.pointCostPerUnit else { return 0 }
        return cost * units
    }

    var canRedeem: Bool {
        guard selectedRule != nil else { return false }
        guard thresholdMet else { return false }
        if pointsToDeduct > 0 && child.balance < pointsToDeduct { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Reward Rule") {
                    Picker("Rule", selection: $selectedRule) {
                        Text("Select a rule").tag(Optional<Rule>.none)
                        ForEach(activeRules) { rule in
                            Text(rule.name).tag(Optional(rule))
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                if let rule = selectedRule {
                    if rule.pointCostPerUnit != nil {
                        Section("Amount") {
                            Stepper(
                                "**\(units)** \(rule.unitLabel ?? "unit(s)")",
                                value: $units, in: 1...999
                            )
                            LabeledContent("Points to deduct", value: "\(pointsToDeduct) pts")
                                .foregroundStyle(child.balance >= pointsToDeduct ? Color.primary : Color.red)
                        }
                    }

                    if let amount = rule.thresholdAmount, let period = rule.thresholdPeriod {
                        Section("Threshold Check") {
                            LabeledContent("Required", value: "≥\(amount) pts this \(period.rawValue)")
                            LabeledContent(
                                "Earned this \(period.rawValue)",
                                value: "\(child.earnedInPeriod(period)) pts"
                            )
                            Label(
                                thresholdMet ? "Threshold met" : "Threshold not met",
                                systemImage: thresholdMet ? "checkmark.circle.fill" : "xmark.circle.fill"
                            )
                            .foregroundStyle(thresholdMet ? .green : .red)
                        }
                    }

                    Section("Note (optional)") {
                        TextField("Redemption note", text: $note, axis: .vertical)
                            .lineLimit(3)
                    }
                }
            }
            .navigationTitle("Redeem Reward")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Redeem") { redeem() }
                        .disabled(!canRedeem)
                }
            }
        }
    }

    private func redeem() {
        guard let rule = selectedRule else { return }

        let redemption = Redemption(
            note: note.isEmpty ? nil : note,
            pointsDeducted: pointsToDeduct,
            child: child,
            rule: rule
        )
        context.insert(redemption)

        if pointsToDeduct > 0 {
            let event = PointEvent(
                delta: -pointsToDeduct,
                note: "Redeemed: \(rule.name)",
                child: child,
                rule: rule
            )
            context.insert(event)
        }

        dismiss()
    }
}
