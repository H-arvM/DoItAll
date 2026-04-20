//
//  LifeAdminView.swift
//  DoItAll
//
//  Created by Marc Harvey on 12/02/2026.
//

import SwiftUI

struct LifeAdminView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var viewModel: LifeAdminViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    var onSave: (() -> Void)?

    init(entry: TaskEntry? = nil, initialEntryType: EntryType = .lifeAdmin, onSave: (() -> Void)? = nil) {
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: LifeAdminViewModel(entry: entry, initialEntryType: initialEntryType))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                contentView
                floatingAddButton
            }
            .navigationTitle("Life Admin")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
            .sheet(isPresented: $viewModel.showingSettings) {
                LifeAdminSettingsView()
            }
            .onAppear {
                viewModel.loadTasks(context: viewContext)
            }
        }
    }

    // MARK: - Subviews

    private var contentView: some View {
        VStack(spacing: 0) {
            categoryPills
            Divider()
            taskList
        }
    }

    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        category: category,
                        isSelected: viewModel.selectedCategory == category,
                        action: { viewModel.selectCategory(category) }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }

    private var taskList: some View {
        Group {
            if viewModel.filteredTasks.isEmpty {
                EmptyStateView(category: viewModel.selectedCategory)
            } else {
                List {
                    ForEach(viewModel.filteredTasks) { task in
                        TaskRow(task: task) {
                            viewModel.toggleTaskCompletion(task, context: viewContext)
                        }
                    }
                    .onDelete { offsets in
                        viewModel.deleteTask(at: offsets, context: viewContext)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    viewModel.showingAddTask = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(themeManager.selectedTheme.primaryColour)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $viewModel.showingAddTask) {
            AddTaskView(viewModel: viewModel)
        }
    }
    
    private var saveButton: some View {
        Button {
            viewModel.saveAdminEntry(context: viewContext) {
            if let onSave = onSave {
                    onSave()
                } else {
                    dismiss()
                }
            }
        } label: {
            Image(systemName: "square.and.arrow.down")
                .foregroundStyle(themeManager.selectedTheme.primaryColour)
        }
    }
}

// MARK: - Preview
struct LifeAdminView_Previews: PreviewProvider {
    static var previews: some View {
        LifeAdminView()
    }
}

