import SwiftUI
import SwiftData

struct AddEventView: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Rule.name) private var rules: [Rule]

    @State private var selectedRule: Rule?
    @State private var amount = 1
    @State private var isPositive = true
    @State private var note = ""

    var activeRules: [Rule] { rules.filter { !$0.isArchived } }

    var body: some View {
        NavigationStack {
            Form {
                Section("Points") {
                    Picker("Type", selection: $isPositive) {
                        Text("Award (+)").tag(true)
                        Text("Remove (-)").tag(false)
                    }
                    .pickerStyle(.segmented)
                    Stepper(
                        "**\(isPositive ? "+" : "-")\(amount)** pts",
                        value: $amount, in: 1...999
                    )
                }

                Section("Category (optional)") {
                    Picker("Rule", selection: $selectedRule) {
                        Text("None").tag(Optional<Rule>.none)
                        ForEach(activeRules) { rule in
                            Text(rule.name).tag(Optional(rule))
                        }
                    }
                }

                Section("Note (optional)") {
                    TextField("What did they do?", text: $note, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle("Log Points")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        let delta = isPositive ? amount : -amount
        let event = PointEvent(
            delta: delta,
            note: note.isEmpty ? nil : note,
            child: child,
            rule: selectedRule
        )
        context.insert(event)
        dismiss()
    }
}
