import CoreData
import SwiftUI

struct ChildListView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.dismiss) private var dismiss

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Child.createdAt, ascending: true)],
    animation: .default)
  private var children: FetchedResults<Child>

  @AppStorage("selectedChildId") private var selectedChildId: String = ""
  @State private var showingAddChild = false
  @State private var childToEdit: Child?
  @State private var arrowBounce = false

  var body: some View {
    NavigationStack {
      Group {
        if children.isEmpty {
          // Empty state: guide pointing to top-right + button
          ZStack(alignment: .topTrailing) {

            // Bouncing arrow toward + button
            VStack(alignment: .trailing, spacing: 2) {
              Image(systemName: "arrow.up.right")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.orange)
                .offset(y: arrowBounce ? -6 : 0)
                .animation(
                  .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                  value: arrowBounce
                )
              Text("ここから登録！")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            }
            .padding(.top, 8)
            .padding(.trailing, 16)
            .onAppear { arrowBounce = true }

            // Center content
            VStack(spacing: 24) {
              Spacer()

              Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 72))
                .foregroundColor(.orange.opacity(0.85))
                .symbolRenderingMode(.hierarchical)

              VStack(spacing: 8) {
                Text("子どもを登録しましょう")
                  .font(.title3)
                  .fontWeight(.bold)
                  .foregroundColor(.primary)

                Text("右上の「＋」ボタンから\n子どもの情報を登録すると\n成長記録が使えるようになります。")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                  .multilineTextAlignment(.center)
                  .lineSpacing(4)
              }

              Button(action: { showingAddChild = true }) {
                HStack(spacing: 8) {
                  Image(systemName: "plus.circle.fill")
                  Text("登録をはじめる")
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: 220)
                .padding(.vertical, 12)
              }
              .buttonStyle(.borderedProminent)
              .tint(.orange)
              .controlSize(.large)

              Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 32)
          }
        } else {
          List {
            ForEach(children) { child in
              HStack {
                VStack(alignment: .leading) {
                  Text(child.name ?? "子ども")
                    .font(.headline)
                  if let birthday = child.birthday {
                    Text(birthday.formatted(date: .long, time: .omitted))
                      .font(.subheadline)
                      .foregroundColor(.secondary)
                  }
                }
                Spacer()
                if child.id?.uuidString == selectedChildId
                  || (selectedChildId.isEmpty && child == children.first)
                {
                  Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                }
              }
              .contentShape(Rectangle())
              .onTapGesture {
                if let idString = child.id?.uuidString {
                  selectedChildId = idString
                  dismiss()
                }
              }
              .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                  childToEdit = child
                } label: {
                  Label("編集", systemImage: "pencil")
                }
                .tint(.orange)
              }
            }
          }
        }
      }
      .navigationTitle("子どもの選択")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingAddChild = true
          } label: {
            Image(systemName: "plus")
          }
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button("閉じる") { dismiss() }
        }
      }
      .sheet(isPresented: $showingAddChild) {
        ChildProfileView(child: nil)
      }
      .sheet(item: $childToEdit) { child in
        ChildProfileView(child: child)
      }
    }
  }
}
