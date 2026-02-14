//
//  Persistence.swift
//  Yatta
//
//  Created by 茂木文章 on 2026/02/14.
//

import CoreData

struct PersistenceController {
  static let shared = PersistenceController()

  @MainActor
  static let preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    let child = Child(context: viewContext)
    child.id = UUID()
    child.name = "太郎"
    child.birthday = Calendar.current.date(byAdding: .month, value: -6, to: Date())
    child.createdAt = Date()

    for i in 0..<10 {
      let newMilestone = Milestone(context: viewContext)
      newMilestone.id = UUID()
      newMilestone.title = "Milestone \(i)"
      newMilestone.date = Date()
      newMilestone.createdAt = Date()
      newMilestone.child = child
    }
    do {
      try viewContext.save()
    } catch {
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    return result
  }()

  let container: NSPersistentCloudKitContainer

  init(inMemory: Bool = false) {
    container = NSPersistentCloudKitContainer(name: "Yatta")
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    container.viewContext.automaticallyMergesChangesFromParent = true
  }
}
