import SwiftUI

struct ChildProfileView: View {
  @State var viewModel: ChildProfileViewModel
  @Environment(\.dismiss) var dismiss
  @State private var showingDeleteAlert = false

  init(child: Child? = nil) {
    _viewModel = State(initialValue: ChildProfileViewModel(child: child))
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("名前", text: $viewModel.name)
          DatePicker("誕生日", selection: $viewModel.birthday, displayedComponents: .date)
          Picker("性別", selection: $viewModel.gender) {
            Text("未選択").tag(Int16(0))
            Text("男の子").tag(Int16(1))
            Text("女の子").tag(Int16(2))
            Text("その他").tag(Int16(3))
          }
        } header: {
          Text("プロフィール")
        }
      }
      .navigationTitle(viewModel.isNew ? "子どもの登録" : "プロフィールの編集")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("キャンセル") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("保存") {
            if viewModel.save() {
              dismiss()
            }
          }
          .disabled(viewModel.name.isEmpty)
        }
      }
    }
  }
}
