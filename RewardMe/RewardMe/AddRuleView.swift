import SwiftUI
import SwiftData

struct AddRuleView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var desc = ""
    @State private var hasCost = false
    @State private var pointCost = 1
    @State private var unitLabel = ""
    @State private var hasThreshold = false
    @State private var thresholdAmount = 10
    @State private var thresholdPeriod = ThresholdPeriod.daily

    var body: some View {
        NavigationStack {
            Form {
                Section("Rule Info") {
                    TextField("Name", text: $name)
                    TextField("Description (optional)", text: $desc, axis: .vertical)
                        .lineLimit(3)
                }

                Section {
                    Toggle("Changes points on redemption", isOn: $hasCost)
                    if hasCost {
                        Stepper("**\(pointCost)** pt per unit", value: $pointCost, in: 1...999)
                        TextField("Unit label (e.g. dollar)", text: $unitLabel)
                    }
                } header: {
                    Text("Point Cost")
                } footer: {
                    if hasCost {
                        Text("Redeeming deducts \(pointCost) pt per \(unitLabel.isEmpty ? "unit" : unitLabel).")
                    }
                }

                Section {
                    Toggle("Requires a point threshold", isOn: $hasThreshold)
                    if hasThreshold {
                        Stepper("**\(thresholdAmount)** pts required", value: $thresholdAmount, in: 1...9999)
                        Picker("Period", selection: $thresholdPeriod) {
                            ForEach(ThresholdPeriod.allCases, id: \.self) { period in
                                Text(period.label).tag(period)
                            }
                        }
                    }
                } header: {
                    Text("Threshold")
                } footer: {
                    if hasThreshold {
                        Text("Child must earn ≥\(thresholdAmount) pts within the \(thresholdPeriod.rawValue) to redeem.")
                    }
                }
            }
            .navigationTitle("Add Rule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let rule = Rule(
            name: name.trimmingCharacters(in: .whitespaces),
            desc: desc.trimmingCharacters(in: .whitespaces),
            pointCostPerUnit: hasCost ? pointCost : nil,
            unitLabel: hasCost && !unitLabel.isEmpty ? unitLabel : nil,
            thresholdAmount: hasThreshold ? thresholdAmount : nil,
            thresholdPeriod: hasThreshold ? thresholdPeriod : nil
        )
        context.insert(rule)
        dismiss()
    }
}
