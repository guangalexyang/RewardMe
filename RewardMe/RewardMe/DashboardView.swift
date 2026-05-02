import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Child.name) private var children: [Child]
    @State private var showingAddChild = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(children) { child in
                    NavigationLink(destination: ChildDetailView(child: child)) {
                        ChildRow(child: child)
                    }
                }
                .onDelete(perform: deleteChildren)
            }
            .navigationTitle("RewardMe")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddChild = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddChild) {
                AddChildView()
            }
            .overlay {
                if children.isEmpty {
                    ContentUnavailableView(
                        "No Children Yet",
                        systemImage: "person.badge.plus",
                        description: Text("Tap + to add your first child")
                    )
                }
            }
        }
    }

    private func deleteChildren(at offsets: IndexSet) {
        for i in offsets { context.delete(children[i]) }
    }
}

struct ChildRow: View {
    let child: Child

    var body: some View {
        HStack(spacing: 12) {
            Text(child.emoji).font(.title)
            VStack(alignment: .leading, spacing: 2) {
                Text(child.name).font(.headline)
                Text("\(child.balance) pts")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(child.balance)")
                .font(.title2.bold())
                .foregroundStyle(child.balance >= 0 ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}
