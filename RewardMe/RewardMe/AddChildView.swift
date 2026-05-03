import SwiftUI
import SwiftData

struct AddChildView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var emoji = "⭐️"

    let emojiOptions = ["⭐️", "🌟", "🦁", "🐯", "🐻", "🐼", "🦊", "🐸", "🦋", "🚀"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Child's name", text: $name)
                }
                Section("Avatar") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(emojiOptions, id: \.self) { e in
                            Text(e)
                                .font(.largeTitle)
                                .padding(8)
                                .background(e == emoji ? Color.accentColor.opacity(0.2) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture { emoji = e }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let child = Child(name: name.trimmingCharacters(in: .whitespaces), emoji: emoji)
        context.insert(child)
        dismiss()
    }
}
