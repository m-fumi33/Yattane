import Foundation

@testable import Yattane

class MockMilestoneRepository: MilestoneRepositoryProtocol {
  var shouldThrowError = false
  var didCallAddMilestone = false
  var savedTitle: String?
  var savedDate: Date?
  var savedPhotoDataList: [Data]?
  var savedNote: String?
  var savedChild: Child?

  var fetchResult: [Milestone] = []

  func fetchMilestones(for child: Child) throws -> [Milestone] {
    if shouldThrowError {
      throw NSError(domain: "TestError", code: 1, userInfo: nil)
    }
    return fetchResult
  }

  func addMilestone(title: String, date: Date, photoDataList: [Data], note: String?, child: Child)
    throws
  {
    didCallAddMilestone = true
    savedTitle = title
    savedDate = date
    savedPhotoDataList = photoDataList
    savedNote = note
    savedChild = child

    if shouldThrowError {
      throw NSError(domain: "TestError", code: 1, userInfo: nil)
    }
  }

  func deleteMilestone(_ milestone: Yattane.Milestone) throws {
    if shouldThrowError {
      throw NSError(domain: "TestError", code: 1, userInfo: nil)
    }
  }

  func deleteAllMilestones(for child: Yattane.Child) throws {
    if shouldThrowError {
      throw NSError(domain: "TestError", code: 1, userInfo: nil)
    }
  }
}
