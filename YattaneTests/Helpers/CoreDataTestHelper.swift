import CoreData

@testable import Yattane

class CoreDataTestHelper {
  static var previewContext: NSManagedObjectContext {
    let controller = PersistenceController(inMemory: true)
    return controller.container.viewContext
  }

  static func createDummyChild(in context: NSManagedObjectContext) -> Child {
    let child = Child(context: context)
    child.id = UUID()
    child.name = "テスト太郎"
    child.birthday = Date()
    child.createdAt = Date()
    return child
  }
}
