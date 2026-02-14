import SwiftUI

struct MilestoneListView: View {
    @State private var viewModel = MilestoneListViewModel()
    @State private var showingAddMilestone = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.milestones) { milestone in
                    MilestoneRow(milestone: milestone)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .onDelete(perform: deleteMilestones)
            }
            .listStyle(.plain)
            .navigationTitle("Yatta!")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMilestone = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddMilestone) {
                AddMilestoneView()
                    .onDisappear {
                        viewModel.fetchMilestones()
                    }
            }
            .onAppear {
                viewModel.fetchMilestones()
            }
        }
    }

    private func deleteMilestones(at offsets: IndexSet) {
        viewModel.deleteMilestone(at: offsets)
    }
}
