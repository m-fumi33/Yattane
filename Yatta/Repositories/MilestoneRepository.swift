import CoreData

protocol MilestoneRepositoryProtocol {
  func fetchMilestones(for child: Child) throws -> [Milestone]
  func addMilestone(title: String, date: Date, photoData: Data?, note: String?, child: Child) throws
  func deleteMilestone(_ milestone: Milestone) throws
  func deleteAllMilestones(for child: Child) throws
}

class MilestoneRepository: MilestoneRepositoryProtocol {
  private let context: NSManagedObjectContext

  init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
    self.context = context
  }

  func fetchMilestones(for child: Child) throws -> [Milestone] {
    let request = NSFetchRequest<Milestone>(entityName: "Milestone")
    request.predicate = NSPredicate(format: "child == %@", child)
    request.sortDescriptors = [NSSortDescriptor(keyPath: \Milestone.date, ascending: false)]
    return try context.fetch(request)
  }

  func addMilestone(title: String, date: Date, photoData: Data?, note: String?, child: Child) throws
  {
    let milestone = Milestone(context: context)
    milestone.id = UUID()
    milestone.title = title
    milestone.date = date
    milestone.photoData = photoData
    milestone.note = note
    milestone.createdAt = Date()
    milestone.child = child

    if context.hasChanges {
      try context.save()
    }
  }

  func deleteMilestone(_ milestone: Milestone) throws {
    context.delete(milestone)
    if context.hasChanges {
      try context.save()
    }
  }
  func deleteAllMilestones(for child: Child) throws {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Milestone.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "child == %@", child)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs  // Important for merging changes

    let batchDeleteResult = try context.execute(deleteRequest) as? NSBatchDeleteResult

    if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
      NSManagedObjectContext.mergeChanges(
        fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs], into: [context])
    }
  }
}
