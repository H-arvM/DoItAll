//
//  AddTaskView.swift
//  DoItAll
//
//  Created by Marc Harvey on 20/04/2026.
//

import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: LifeAdminViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $viewModel.itemName)

                    TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        Text("None").tag(TaskCategory?.none)
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(TaskCategory?.some(category))
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Due Date") {
                    Toggle("Set due date", isOn: $viewModel.hasDueDate)

                    if viewModel.hasDueDate {
                        DatePicker(
                            "Due",
                            selection: Binding(
                                get: { viewModel.dueDate ?? Date() },
                                set: { viewModel.dueDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.itemName = ""
                        viewModel.notes = ""
                        viewModel.dueDate = nil
                        viewModel.hasDueDate = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addTask(context: viewContext)
                        dismiss()
                    }
                    .disabled(viewModel.itemName.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
//
//#Preview {
//    AddTaskView()
//}
