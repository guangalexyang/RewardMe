import SwiftUI
import SwiftData

struct ChildDetailView: View {
    let child: Child
    @State private var showingAddEvent = false
    @State private var showingRedeem = false

    var sortedEvents: [PointEvent] {
        child.events.sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Text(child.emoji).font(.system(size: 64))
                    Text("\(child.balance) pts")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(child.balance >= 0 ? .green : .red)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }

            Section {
                HStack(spacing: 12) {
                    Button { showingAddEvent = true } label: {
                        Label("Log Points", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button { showingRedeem = true } label: {
                        Label("Redeem", systemImage: "gift.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 4)
            }

            Section("History") {
                if sortedEvents.isEmpty {
                    Text("No events yet").foregroundStyle(.secondary)
                } else {
                    ForEach(sortedEvents) { event in
                        EventRow(event: event)
                    }
                }
            }
        }
        .navigationTitle(child.name)
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(child: child)
        }
        .sheet(isPresented: $showingRedeem) {
            RedeemView(child: child)
        }
    }
}

struct EventRow: View {
    let event: PointEvent

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(event.rule?.name ?? "Manual")
                    .font(.subheadline.weight(.medium))
                if let note = event.note, !note.isEmpty {
                    Text(note).font(.caption).foregroundStyle(.secondary)
                }
                Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2).foregroundStyle(.tertiary)
            }
            Spacer()
            Text(event.delta > 0 ? "+\(event.delta)" : "\(event.delta)")
                .font(.headline.bold())
                .foregroundStyle(event.delta > 0 ? .green : .red)
        }
    }
}
