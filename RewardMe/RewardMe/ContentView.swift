import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Family", systemImage: "person.2.fill") {
                DashboardView()
            }
            Tab("Rules", systemImage: "list.bullet.clipboard") {
                RulesListView()
            }
        }
    }
}
