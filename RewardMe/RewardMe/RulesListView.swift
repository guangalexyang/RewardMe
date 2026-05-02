import SwiftUI
import SwiftData

struct RulesListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Rule.name) private var rules: [Rule]
    @State private var showingAddRule = false

    var activeRules: [Rule] { rules.filter { !$0.isArchived } }
    var archivedRules: [Rule] { rules.filter { $0.isArchived } }

    var body: some View {
        NavigationStack {
            List {
                Section("Active") {
                    if activeRules.isEmpty {
                        Text("No rules yet").foregroundStyle(.secondary)
                    } else {
                        ForEach(activeRules) { rule in
                            RuleRow(rule: rule)
                                .swipeActions {
                                    Button("Archive") { rule.isArchived = true }
                                        .tint(.orange)
                                }
                        }
                    }
                }

                if !archivedRules.isEmpty {
                    Section("Archived") {
                        ForEach(archivedRules) { rule in
                            RuleRow(rule: rule)
                                .swipeActions {
                                    Button("Restore") { rule.isArchived = false }
                                        .tint(.green)
                                    Button("Delete", role: .destructive) { context.delete(rule) }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Rules")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddRule = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRule) {
                AddRuleView()
            }
            .overlay {
                if rules.isEmpty {
                    ContentUnavailableView(
                        "No Rules Yet",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Tap + to create your first rule")
                    )
                }
            }
        }
    }
}

struct RuleRow: View {
    let rule: Rule

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(rule.name).font(.headline)
                if rule.isArchived {
                    Text("Archived")
                        .font(.caption)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(.secondary.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            if !rule.desc.isEmpty {
                Text(rule.desc).font(.subheadline).foregroundStyle(.secondary)
            }
            Text(rule.summary).font(.caption).foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}
