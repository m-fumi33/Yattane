import CoreData
import SwiftUI

@Observable
class ChildProfileViewModel {
  var name: String = ""
  var birthday: Date = Date()
  var gender: Int16 = 0  // 0: Unknown, 1: Male, 2: Female, 3: Other
  var isNew: Bool = true

  private let repository: ChildRepositoryProtocol
  private var child: Child?

  init(child: Child? = nil, repository: ChildRepositoryProtocol = ChildRepository()) {
    self.repository = repository
    self.child = child
    if let child = child {
      self.name = child.name ?? ""
      self.birthday = child.birthday ?? Date()
      self.gender = child.gender
      self.isNew = false
    }
  }

  func save() -> Bool {
    if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return false
    }

    do {
      if let child = child {
        try repository.updateChild(child, name: name, birthday: birthday, gender: gender)
      } else {
        try repository.addChild(name: name, birthday: birthday, gender: gender)
      }
      return true
    } catch {
      print("Failed to save child: \(error)")
      return false
    }
  }

  func delete() -> Bool {
    guard let child = child else { return false }
    do {
      try repository.deleteChild(child)
      return true
    } catch {
      print("Failed to delete child: \(error)")
      return false
    }
  }
}
