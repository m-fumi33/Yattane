import SwiftUI
import PhotosUI

struct AddMilestoneView: View {
    @State private var viewModel = AddMilestoneViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title (e.g. First Smile)", text: $viewModel.title)
                    DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                } header: {
                    Text("Details")
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
                                Text("Select Photo")
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
                    Text("Photo")
                }
                
                Section {
                    TextEditor(text: $viewModel.note)
                        .frame(height: 100)
                } header: {
                    Text("Note")
                }
            }
            .navigationTitle("New Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save()
                        dismiss()
                    }
                    .disabled(viewModel.title.isEmpty)
                }
            }
        }
    }
}
