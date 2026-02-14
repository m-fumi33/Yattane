//
//  YattaApp.swift
//  Yatta
//
//  Created by m-fumi3 on 2026/02/14.
//

import CoreData
import SwiftUI

@main
struct YattaApp: App {
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environment(\.locale, Locale(identifier: "ja_JP"))
    }
  }
}
