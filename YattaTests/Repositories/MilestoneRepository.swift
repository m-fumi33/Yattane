import CoreData

protocol MilestoneRepositoryProtocol {
    func fetchMilestones() throws -> [Milestone]
    func addMilestone(title: String, date: Date, photoData: Data?, note: String?) throws
    func deleteMilestone(_ milestone: Milestone) throws
}

class MilestoneRepository: MilestoneRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func fetchMilestones() throws -> [Milestone] {
        let request = NSFetchRequest<Milestone>(entityName: "Milestone")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Milestone.date, ascending: false)]
        return try context.fetch(request)
    }

    func addMilestone(title: String, date: Date, photoData: Data?, note: String?) throws {
        let milestone = Milestone(context: context)
        milestone.id = UUID()
        milestone.title = title
        milestone.date = date
        milestone.photoData = photoData
        milestone.note = note
        milestone.createdAt = Date()
        
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
}
