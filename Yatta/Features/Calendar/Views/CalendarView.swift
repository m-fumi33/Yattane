import SwiftUI
import UIKit

struct CalendarView: UIViewRepresentable {
  let milestones: [Milestone]
  @Binding var selectedDate: Date

  func makeUIView(context: Context) -> UICalendarView {
    let calendarView = UICalendarView()
    calendarView.calendar = Calendar(identifier: .gregorian)
    calendarView.locale = .current
    calendarView.fontDesign = .rounded
    calendarView.delegate = context.coordinator
    calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
    return calendarView
  }

  func updateUIView(_ uiView: UICalendarView, context: Context) {
    context.coordinator.milestones = milestones
    // Reload decorations when milestones change
    let dates = milestones.compactMap { $0.date }.map { Calendar.current.startOfDay(for: $0) }
    uiView.reloadDecorations(
      forDateComponents: dates.map {
        Calendar.current.dateComponents([.year, .month, .day], from: $0)
      }, animated: true)
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    var parent: CalendarView
    var milestones: [Milestone] = []

    init(parent: CalendarView) {
      self.parent = parent
    }

    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents)
      -> UICalendarView.Decoration?
    {
      guard let date = dateComponents.date else { return nil }
      let found = milestones.contains { Calendar.current.isDate($0.date!, inSameDayAs: date) }

      if found {
        return .default(color: .systemOrange, size: .small)
      }
      return nil
    }

    func dateSelection(
      _ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?
    ) {
      if let date = dateComponents?.date {
        parent.selectedDate = date
      }
    }
  }
}

struct CalendarTabWrapper: View {
  @State private var selectedDate = Date()
  @State private var milestones: [Milestone] = []
  @State private var selectedChild: Child?

  private let milestoneRepository = MilestoneRepository()
  private let childRepository = ChildRepository()

  var body: some View {
    NavigationStack {
      VStack {
        if selectedChild != nil {
          CalendarView(milestones: milestones, selectedDate: $selectedDate)
            .padding()

          // Show milestones for selected date
          List {
            ForEach(
              milestones.filter { Calendar.current.isDate($0.date!, inSameDayAs: selectedDate) }
            ) { milestone in
              MilestoneRow(milestone: milestone)
            }
          }
          .listStyle(.plain)
        } else {
          ContentUnavailableView {
            Label("子どもを登録してください", systemImage: "person.crop.circle.badge.plus")
          } description: {
            Text("左上のメニューから\n子どもを追加・選択できます")
          }
        }
      }
      .navigationTitle(selectedChild?.name ?? "カレンダー")
      .onAppear {
        fetchData()
      }
    }
  }

  private func fetchData() {
    do {
      let children = try childRepository.fetchChildren()
      if selectedChild == nil {
        selectedChild = children.first
      }

      if let child = selectedChild {
        milestones = try milestoneRepository.fetchMilestones(for: child)
      } else {
        milestones = []
      }
    } catch {
      print("Error fetching: \(error)")
    }
  }
}
