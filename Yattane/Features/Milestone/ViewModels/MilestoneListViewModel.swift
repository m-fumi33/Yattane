import SwiftUI
import CoreData

@Observable
class MilestoneListViewModel {
    var milestones: [Milestone] = []
    private let repository: MilestoneRepositoryProtocol

    init(repository: MilestoneRepositoryProtocol = MilestoneRepository()) {
        self.repository = repository
        fetchMilestones()
    }

    func fetchMilestones() {
        do {
            milestones = try repository.fetchMilestones()
        } catch {
            print("Failed to fetch milestones: \(error)")
        }
    }

    func deleteMilestone(at offsets: IndexSet) {
        for index in offsets {
            let milestone = milestones[index]
            do {
                try repository.deleteMilestone(milestone)
                milestones.remove(at: index)
            } catch {
                print("Failed to delete milestone: \(error)")
            }
        }
    }
}
