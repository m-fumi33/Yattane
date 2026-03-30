import XCTest

@testable import Yattane

@MainActor
final class AddMilestoneViewModelTests: XCTestCase {
  var viewModel: AddMilestoneViewModel!
  var mockRepository: MockMilestoneRepository!
  var child: Child!

  override func setUp() async throws {
    try await super.setUp()
    let context = CoreDataTestHelper.previewContext
    child = CoreDataTestHelper.createDummyChild(in: context)
    mockRepository = MockMilestoneRepository()
    viewModel = AddMilestoneViewModel(child: child, repository: mockRepository)
  }

  override func tearDown() async throws {
    viewModel = nil
    mockRepository = nil
    child = nil
    try await super.tearDown()
  }

  func test_save_withEmptyTitle_shouldFailAndShowAlert() {
    // Arrange
    viewModel.title = "   "  // Empty or whitespaces

    // Act
    let result = viewModel.save()

    // Assert
    XCTAssertFalse(result)
    XCTAssertTrue(viewModel.showAlert)
    XCTAssertEqual(viewModel.errorMessage, "タイトルを入力してください。")
    XCTAssertFalse(mockRepository.didCallAddMilestone)
  }

  func test_save_withValidData_shouldSucceedAndCallRepository() {
    // Arrange
    let testDate = Date()
    viewModel.title = "はじめて歩いた"
    viewModel.date = testDate
    viewModel.note = "すごく嬉しかった"

    // Act
    let result = viewModel.save()

    // Assert
    XCTAssertTrue(result)
    XCTAssertFalse(viewModel.showAlert)
    XCTAssertTrue(mockRepository.didCallAddMilestone)
    XCTAssertEqual(mockRepository.savedTitle, "はじめて歩いた")
    XCTAssertEqual(mockRepository.savedDate, testDate)
    XCTAssertEqual(mockRepository.savedNote, "すごく嬉しかった")
  }

  func test_save_whenRepositoryThrowsError_shouldFailAndShowAlert() {
    // Arrange
    viewModel.title = "テスト"
    mockRepository.shouldThrowError = true

    // Act
    let result = viewModel.save()

    // Assert
    XCTAssertFalse(result)
    XCTAssertTrue(viewModel.showAlert)
    XCTAssertEqual(viewModel.errorMessage, "保存に失敗しました。")
    XCTAssertTrue(mockRepository.didCallAddMilestone)
  }
}
