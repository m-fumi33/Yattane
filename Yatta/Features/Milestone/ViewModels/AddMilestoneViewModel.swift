import PhotosUI
import SwiftUI

@Observable
class AddMilestoneViewModel {
  var title: String = ""
  var date: Date = Date()
  var note: String = ""
  var selectedPhotoItem: PhotosPickerItem? = nil
  var selectedPhotoData: Data? = nil
  var showAlert = false
  var errorMessage = ""

  private let repository: MilestoneRepositoryProtocol
  private let child: Child

  init(child: Child, repository: MilestoneRepositoryProtocol = MilestoneRepository()) {
    self.child = child
    self.repository = repository
  }

  func save() -> Bool {
    if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      errorMessage = "タイトルを入力してください。"
      showAlert = true
      return false
    }

    // Photo and Note are now optional, so no validation needed for them.

    do {
      try repository.addMilestone(
        title: title, date: date, photoData: selectedPhotoData, note: note.isEmpty ? nil : note,
        child: child)
      return true
    } catch {
      print("Failed to save milestone: \(error)")
      errorMessage = "保存に失敗しました。"
      showAlert = true
      return false
    }
  }

  @MainActor
  func loadPhoto(from item: PhotosPickerItem?) async {
    guard let item = item else { return }
    do {
      if let data = try await item.loadTransferable(type: Data.self) {
        selectedPhotoData = data
      }
    } catch {
      print("Failed to load photo: \(error)")
    }
  }
}
