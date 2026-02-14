import SwiftUI
import PhotosUI

@Observable
class AddMilestoneViewModel {
    var title: String = ""
    var date: Date = Date()
    var note: String = ""
    var selectedPhotoItem: PhotosPickerItem? = nil
    var selectedPhotoData: Data? = nil
    
    private let repository: MilestoneRepositoryProtocol

    init(repository: MilestoneRepositoryProtocol = MilestoneRepository()) {
        self.repository = repository
    }

    func save() {
        do {
            try repository.addMilestone(title: title, date: date, photoData: selectedPhotoData, note: note.isEmpty ? nil : note)
        } catch {
            print("Failed to save milestone: \(error)")
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
