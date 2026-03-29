import SwiftUI
import UIKit

// MARK: - UIKit container that scales UICalendarView via CGAffineTransform
// This keeps all content (month header, weekday labels, date cells) fully visible
// while making the calendar compact. Unlike SwiftUI scaleEffect, the transform
// is applied at the UIKit level so layout and clipping work correctly.
final class ScaledCalendarContainer: UIView {
  let calendarView = UICalendarView()
  private let displayScale: CGFloat
  /// Cached scaled height — updated in layoutSubviews, read in intrinsicContentSize.
  private var cachedScaledHeight: CGFloat = 350

  init(scale: CGFloat) {
    self.displayScale = scale
    super.init(frame: .zero)
    addSubview(calendarView)
  }

  required init?(coder: NSCoder) { fatalError() }

  override func layoutSubviews() {
    super.layoutSubviews()
    guard bounds.width > 0 else { return }

    // Reset transform to measure natural size
    calendarView.transform = .identity
    let naturalWidth = bounds.width / displayScale
    calendarView.frame = CGRect(x: 0, y: 0, width: naturalWidth, height: 600)
    calendarView.layoutIfNeeded()

    let fittingSize = calendarView.sizeThatFits(
      CGSize(width: naturalWidth, height: .greatestFiniteMagnitude)
    )
    let naturalHeight = fittingSize.height > 50 ? fittingSize.height : 480
    calendarView.frame = CGRect(x: 0, y: 0, width: naturalWidth, height: naturalHeight)

    // Anchor top-left, then scale
    calendarView.layer.anchorPoint = CGPoint(x: 0, y: 0)
    calendarView.layer.position = .zero
    calendarView.transform = CGAffineTransform(scaleX: displayScale, y: displayScale)

    // Cache height and defer invalidation to next run loop to avoid infinite layout cycle
    let newHeight = naturalHeight * displayScale
    if abs(newHeight - cachedScaledHeight) > 1 {
      cachedScaledHeight = newHeight
      DispatchQueue.main.async { [weak self] in
        self?.invalidateIntrinsicContentSize()
      }
    }
  }

  override var intrinsicContentSize: CGSize {
    // Return cached value — never modify transform here to avoid triggering layout
    CGSize(width: UIView.noIntrinsicMetric, height: cachedScaledHeight)
  }
}

// MARK: - CalendarView (UIViewRepresentable)
struct CalendarView: UIViewRepresentable {
  let milestones: [Milestone]
  @Binding var selectedDate: Date
  var scale: CGFloat = 0.65

  func makeUIView(context: Context) -> ScaledCalendarContainer {
    let container = ScaledCalendarContainer(scale: scale)
    let cal = container.calendarView
    cal.calendar = Calendar(identifier: .gregorian)
    cal.locale = .current
    cal.fontDesign = .rounded
    cal.delegate = context.coordinator
    cal.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
    return container
  }

  func updateUIView(_ container: ScaledCalendarContainer, context: Context) {
    context.coordinator.milestones = milestones
    let dates = milestones.compactMap { $0.date }.map { Calendar.current.startOfDay(for: $0) }
    container.calendarView.reloadDecorations(
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

// MARK: - CalendarTabWrapper
struct CalendarTabWrapper: View {
  @State private var selectedDate = Date()
  @State private var milestones: [Milestone] = []
  @State private var searchText: String = ""
  private let repository = MilestoneRepository()
  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Child.createdAt, ascending: true)],
    animation: .default)
  private var children: FetchedResults<Child>
  @AppStorage("selectedChildId") private var selectedChildId: String = ""

  /// Actual safe area top inset from UIKit (accurate for all devices including Dynamic Island)
  private var safeAreaTop: CGFloat {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first?.keyWindow?.safeAreaInsets.top ?? 47
  }

  private var activeChild: Child? {
    if let matched = children.first(where: { $0.id?.uuidString == selectedChildId }) {
      return matched
    }
    return children.first
  }

  /// Filtered milestones for search results
  private var searchResults: [Milestone] {
    let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !query.isEmpty else { return [] }
    return milestones.filter { milestone in
      let titleMatch = (milestone.title ?? "").lowercased().contains(query)
      let noteMatch = (milestone.note ?? "").lowercased().contains(query)
      return titleMatch || noteMatch
    }
    .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
  }

  /// Whether search mode is active
  private var isSearching: Bool {
    !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  var body: some View {
    NavigationStack {
      Group {
        if children.isEmpty {
          VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
              .font(.system(size: 64))
              .foregroundColor(.gray.opacity(0.8))
            Text("子どもを登録するとカレンダーが使えます")
              .font(.headline)
              .foregroundColor(.secondary)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(Color.theme.background)
        } else {
          VStack(spacing: 0) {
            // Custom Header — padding(.top) uses actual UIKit safe area so text never clips
            VStack(alignment: .leading, spacing: 4) {
              Text("カレンダー")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, safeAreaTop + 12)
            .padding(.bottom, 20)
            .background(
              Color.theme.primary
                .clipShape(CustomRoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))
                .ignoresSafeArea()
            )

            // Search Bar
            HStack(spacing: 8) {
              Image(systemName: "magnifyingglass")
                .foregroundColor(.theme.textSecondary)
              TextField("できたことを検索…", text: $searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
              if !searchText.isEmpty {
                Button {
                  searchText = ""
                } label: {
                  Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.theme.textSecondary)
                }
              }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.theme.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.top, 12)

            if isSearching {
              // Search Results List
              if searchResults.isEmpty {
                VStack(spacing: 16) {
                  Spacer()
                  Image(systemName: "magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(.theme.textSecondary.opacity(0.5))
                  Text("「\(searchText)」に一致する記録がありません")
                    .font(.subheadline)
                    .foregroundColor(.theme.textSecondary)
                  Spacer()
                }
                .frame(maxWidth: .infinity)
              } else {
                List {
                  ForEach(searchResults) { milestone in
                    searchResultRow(milestone: milestone)
                      .listRowSeparator(.hidden)
                      .listRowBackground(Color.clear)
                      .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                  }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
              }
            } else {
              // Calendar View Card — scaled at UIKit level (85%)
              // ScaledCalendarContainer applies CGAffineTransform so the month header,
              // weekday labels and all date cells remain fully visible.
              VStack(spacing: 0) {
                CalendarView(milestones: milestones, selectedDate: $selectedDate)
                  .padding(.horizontal, 4)
              }
              .background(Color.theme.cardBackground)
              .cornerRadius(24)
              .shadow(color: Color.theme.shadow, radius: 10, x: 0, y: 5)
              .padding(.horizontal, 16)
              .padding(.top, 8)

              // Selected Date's Milestones
              List {
                ForEach(
                  milestones.filter {
                    Calendar.current.isDate($0.date!, inSameDayAs: selectedDate)
                  }
                ) { milestone in
                  MilestoneRow(milestone: milestone)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
              }
              .listStyle(.plain)
              .scrollContentBackground(.hidden)
            }
          }
          .background(Color.theme.background)
          .ignoresSafeArea(edges: .top)
        }
      }
      .onAppear {
        fetchMilestones()
      }
      .onChange(of: selectedDate) { oldValue, newValue in
        // Refresh if needed, but data is already loaded
      }
      .onChange(of: selectedChildId) { _, _ in
        fetchMilestones()
      }
    }
  }

  // MARK: - Search Result Row
  private func searchResultRow(milestone: Milestone) -> some View {
    HStack(spacing: 12) {
      // Date column
      VStack(spacing: 2) {
        if let date = milestone.date {
          Text(date.formatted(.dateTime.month(.defaultDigits).day()))
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.theme.primary)
          Text(date.formatted(.dateTime.year()))
            .font(.caption2)
            .foregroundColor(.theme.textSecondary)
        }
      }
      .frame(width: 50)

      // Divider
      RoundedRectangle(cornerRadius: 1)
        .fill(Color.theme.primary.opacity(0.3))
        .frame(width: 2, height: 40)

      // Content
      VStack(alignment: .leading, spacing: 4) {
        Text(milestone.title ?? "無題の記録")
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(.theme.textPrimary)
          .lineLimit(1)
        if let note = milestone.note, !note.isEmpty {
          Text(note)
            .font(.caption)
            .foregroundColor(.theme.textSecondary)
            .lineLimit(2)
        }
      }

      Spacer()

      // Age tag
      if let child = milestone.child, let birthday = child.birthday, let date = milestone.date {
        let components = Calendar.current.dateComponents([.month, .day], from: birthday, to: date)
        let m = components.month ?? 0
        let d = components.day ?? 0
        let ageText = m > 0 ? "\(m)ヶ月\(d > 0 ? "\(d)日" : "")" : "\(d)日"
        Text(ageText)
          .font(.caption2)
          .fontWeight(.medium)
          .foregroundColor(.theme.textPrimary)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color.theme.babyPink)
          .clipShape(Capsule())
      }
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 12)
    .background(Color.theme.cardBackground)
    .cornerRadius(16)
    .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
  }

  private func fetchMilestones() {
    if let child = activeChild {
      do {
        milestones = try repository.fetchMilestones(for: child)
      } catch {
        print("Error fetching: \(error)")
      }
    }
  }
}
