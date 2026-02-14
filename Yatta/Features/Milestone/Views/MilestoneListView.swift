import SwiftUI

struct MilestoneListView: View {
  @State private var viewModel = MilestoneListViewModel()
  @State private var showingAddMilestone = false
  @State private var showingDeleteAllAlert = false
  @State private var showingDeleteOneAlert = false
  @State private var showingChildProfile = false
  @State private var showingAddChild = false
  @State private var showingDeleteChildAlert = false
  @State private var showingDeleteCompletionAlert = false
  @State private var milestoneToDelete: IndexSet?

  var body: some View {
    NavigationStack {
      mainContent
        .listStyle(.plain)
        .navigationTitle(viewModel.selectedChild?.name ?? "やったね！")
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Menu {
              ForEach(viewModel.children) { child in
                Button(child.name ?? "子ども") {
                  viewModel.selectedChild = child
                  viewModel.fetchMilestones()
                }
              }
              Divider()
              if let selected = viewModel.selectedChild {
                Button("\(selected.name ?? "")を編集", systemImage: "pencil") {
                  showingChildProfile = true
                }
                Button("\(selected.name ?? "子ども")を削除", systemImage: "trash") {
                  // Delay prompt slightly to ensure menu dismissal doesn't conflict
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingDeleteChildAlert = true
                  }
                }
              }
              Button("子どもを追加", systemImage: "person.badge.plus") {
                // viewModel.selectedChild = nil // We don't need to nil it here if the sheet creates a new one with nil
                showingAddChild = true
              }
            } label: {
              HStack {
                Text(viewModel.selectedChild?.name ?? "メニュー")
                  .fontWeight(.bold)
                Image(systemName: "chevron.down")
                  .font(.caption)
              }
              .foregroundColor(.primary)
            }
          }

          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showingAddMilestone = true }) {
              HStack(spacing: 4) {
                Text("記録する")
                  .font(.callout)
                  .fontWeight(.medium)
                Image(systemName: "plus.circle.fill")
                  .font(.system(size: 24))
              }
              .foregroundColor(.blue)
            }
            .disabled(viewModel.selectedChild == nil)
          }

          if viewModel.selectedChild != nil {
            ToolbarItem(placement: .bottomBar) {
              Button(action: { showingDeleteAllAlert = true }) {
                Image(systemName: "trash")
                  .foregroundColor(.red)
              }
              .disabled(viewModel.milestones.isEmpty)
            }
          }
        }
        .sheet(isPresented: $showingAddMilestone) {
          if let child = viewModel.selectedChild {
            AddMilestoneView(child: child)
              .onDisappear {
                viewModel.fetchMilestones()
              }
          }
        }
        .sheet(isPresented: $showingChildProfile) {
          // Edit current
          ChildProfileView(child: viewModel.selectedChild)
            .onDisappear {
              viewModel.fetchChildren()  // Refresh name etc
            }
        }
        .sheet(isPresented: $showingAddChild) {  // Changed from showingChildList
          // Add new
          ChildProfileView(child: nil)
            .onDisappear {
              viewModel.fetchChildren()
            }
        }
        .onAppear {
          viewModel.fetchChildren()  // This also fetches milestones
        }
        .alert("全てのデータを削除しますか？", isPresented: $showingDeleteAllAlert) {
          Button("削除", role: .destructive) {
            viewModel.deleteAll()
          }
          Button("キャンセル", role: .cancel) {}
        } message: {
          Text("この操作は取り消せません。")
        }
        .alert("この記録を削除しますか？", isPresented: $showingDeleteOneAlert) {
          Button("削除", role: .destructive) {
            if let offsets = milestoneToDelete {
              viewModel.deleteMilestone(at: offsets)
            }
          }
          Button("キャンセル", role: .cancel) {
            milestoneToDelete = nil
          }
        }
    }
  }

  @ViewBuilder
  private var mainContent: some View {
    List {
      if viewModel.selectedChild != nil {
        ForEach(viewModel.milestones) { milestone in
          MilestoneRow(milestone: milestone)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .onDelete { offsets in
          milestoneToDelete = offsets
          showingDeleteOneAlert = true
        }
      } else {
        ContentUnavailableView {
          Label("子どもを登録してください", systemImage: "person.crop.circle.badge.plus")
        } description: {
          Text("左上のメニューから\n子どもを追加・選択できます")
        }
      }
    }
    .alert(
      "\(viewModel.selectedChild?.name ?? "子ども")を削除しますか？", isPresented: $showingDeleteChildAlert
    ) {
      Button("削除", role: .destructive) {
        viewModel.deleteSelectedChild()
        showingDeleteCompletionAlert = true
      }
      Button("キャンセル", role: .cancel) {}
    } message: {
      Text("この操作は取り消せません。登録されている記録も全て削除されます。")
    }
    .alert("削除しました", isPresented: $showingDeleteCompletionAlert) {
      Button("OK", role: .cancel) {}
    }
  }
}
