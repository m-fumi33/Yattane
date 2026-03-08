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
        uiView.reloadDecorations(forDateComponents: dates.map { Calendar.current.dateComponents([.year, .month, .day], from: $0) }, animated: true)
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

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = dateComponents.date else { return nil }
            let found = milestones.contains { Calendar.current.isDate($0.date!, inSameDayAs: date) }
            
            if found {
                return .default(color: .systemOrange, size: .small)
            }
            return nil
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if let date = dateComponents?.date {
                parent.selectedDate = date
            }
        }
    }
}

struct CalendarTabWrapper: View {
    @State private var selectedDate = Date()
    @State private var milestones: [Milestone] = []
    private let repository = MilestoneRepository()
    
    var body: some View {
        NavigationStack {
            VStack {
                CalendarView(milestones: milestones, selectedDate: $selectedDate)
                    .padding()
                
                // Show milestones for selected date
                List {
                    ForEach(milestones.filter { Calendar.current.isDate($0.date!, inSameDayAs: selectedDate) }) { milestone in
                        MilestoneRow(milestone: milestone)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Calendar")
            .onAppear {
                fetchMilestones()
            }
            .onChange(of: selectedDate) { _ in
                // Refresh if needed, but data is already loaded
            }
        }
    }
    
    private func fetchMilestones() {
        do {
            milestones = try repository.fetchMilestones()
        } catch {
            print("Error fetching: \(error)")
        }
    }
}
