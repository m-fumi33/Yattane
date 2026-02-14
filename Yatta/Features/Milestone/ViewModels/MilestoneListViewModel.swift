import CoreData
import SwiftUI

@Observable
class MilestoneListViewModel {
  var milestones: [Milestone] = []
  var children: [Child] = []
  var selectedChild: Child?

  private let milestoneRepository: MilestoneRepositoryProtocol
  private let childRepository: ChildRepositoryProtocol

  init(
    milestoneRepository: MilestoneRepositoryProtocol = MilestoneRepository(),
    childRepository: ChildRepositoryProtocol = ChildRepository()
  ) {
    self.milestoneRepository = milestoneRepository
    self.childRepository = childRepository
    fetchChildren()
  }

  func fetchChildren() {
    do {
      children = try childRepository.fetchChildren()
      if selectedChild == nil, let firstChild = children.first {
        selectedChild = firstChild
      }
      // If no children, create a default one (fallback logic, though Persistence seeds one)
      if children.isEmpty {
        // We might need to handle this case in the UI or create one here.
        // For now, let's assume Persistence seeded one or UI handles empty state.
      }
      fetchMilestones()
    } catch {
      print("Failed to fetch children: \(error)")
    }
  }

  func fetchMilestones() {
    guard let child = selectedChild else {
      milestones = []
      return
    }
    do {
      milestones = try milestoneRepository.fetchMilestones(for: child)
    } catch {
      print("Failed to fetch milestones: \(error)")
    }
  }

  func deleteMilestone(at offsets: IndexSet) {
    for index in offsets {
      let milestone = milestones[index]
      do {
        try milestoneRepository.deleteMilestone(milestone)
        milestones.remove(at: index)
      } catch {
        print("Failed to delete milestone: \(error)")
      }
    }
  }

  func deleteAll() {
    guard let child = selectedChild else { return }
    do {
      try milestoneRepository.deleteAllMilestones(for: child)
      milestones.removeAll()
    } catch {
      print("Failed to delete all milestones: \(error)")
    }
  }

  func deleteSelectedChild() {
    guard let child = selectedChild else { return }
    do {
      try childRepository.deleteChild(child)
      selectedChild = nil  // Will trigger UI update ? Need to fetchChildren again.
      fetchChildren()
    } catch {
      print("Failed to delete child: \(error)")
    }
  }
}
