import CoreData
import SwiftUI

protocol ChildRepositoryProtocol {
  func fetchChildren() throws -> [Child]
  func addChild(name: String, birthday: Date, gender: Int16) throws
  func updateChild(_ child: Child, name: String, birthday: Date, gender: Int16) throws
  func deleteChild(_ child: Child) throws
}

class ChildRepository: ChildRepositoryProtocol {
  private let context: NSManagedObjectContext

  init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
    self.context = context
  }

  func fetchChildren() throws -> [Child] {
    let request = NSFetchRequest<Child>(entityName: "Child")
    request.sortDescriptors = [NSSortDescriptor(keyPath: \Child.createdAt, ascending: true)]
    return try context.fetch(request)
  }

  func addChild(name: String, birthday: Date, gender: Int16) throws {
    let child = Child(context: context)
    child.id = UUID()
    child.name = name
    child.birthday = birthday
    child.gender = gender
    child.createdAt = Date()

    if context.hasChanges {
      try context.save()
    }
  }

  func updateChild(_ child: Child, name: String, birthday: Date, gender: Int16) throws {
    child.name = name
    child.birthday = birthday
    child.gender = gender
    if context.hasChanges {
      try context.save()
    }
  }

  func deleteChild(_ child: Child) throws {
    context.delete(child)
    if context.hasChanges {
      try context.save()
    }
  }
}
