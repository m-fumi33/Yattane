import PhotosUI
import SwiftUI

struct AddMilestoneView: View {
  @State private var viewModel: AddMilestoneViewModel
  @Environment(\.dismiss) var dismiss

  init(child: Child) {
    _viewModel = State(initialValue: AddMilestoneViewModel(child: child))
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("タイトル (例: 初めて笑った)", text: $viewModel.title)
          DatePicker("日付", selection: $viewModel.date, displayedComponents: .date)
        } header: {
          Text("詳細")
        }

        Section {
          PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
            if let data = viewModel.selectedPhotoData, let uiImage = UIImage(data: data) {
              Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
              HStack {
                Image(systemName: "photo")
                Text("写真を選択")
              }
              .foregroundColor(.blue)
            }
          }
          .onChange(of: viewModel.selectedPhotoItem) { newItem in
            Task {
              await viewModel.loadPhoto(from: newItem)
            }
          }
        } header: {
          Text("写真")
        }

        Section {
          TextEditor(text: $viewModel.note)
            .frame(height: 100)
        } header: {
          Text("メモ")
        }
      }
      .navigationTitle("新しいできたこと")
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
        }
      }
      .alert("入力エラー", isPresented: $viewModel.showAlert) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(viewModel.errorMessage)
      }
    }
  }
}
