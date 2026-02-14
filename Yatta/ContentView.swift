import CoreData
import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
      MilestoneListView()
        .tabItem {
          Label("記録", systemImage: "list.bullet")
        }

      CalendarTabWrapper()
        .tabItem {
          Label("カレンダー", systemImage: "calendar")
        }
    }
  }
}

#Preview {
  ContentView()
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
