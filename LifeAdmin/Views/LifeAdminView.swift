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
    @State private var sheetContentHeight = CGFloat(0)
    
    var onSave: (() -> Void)?
    
    init(entry: TaskEntry? = nil, initialEntryType: EntryType = .lifeAdmin, onSave: (() -> Void)? = nil) {
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: LifeAdminViewModel(entry: entry))
    }
    
    var body: some View {
        ZStack {
            contentView
            floatingAddButton
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarItems }
        .onAppear {
            viewModel.loadTasks(context: viewContext)
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            categoryPills
            PulsingDividerBar()
                .padding(.vertical, 2)
            taskList
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            CancelButton()
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            SaveButton(
                viewModel: viewModel,
                context: viewContext,
                onSave: onSave ?? { dismiss() }
            )
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
                        AdminTaskRow(
                            task: task,
                            onToggle: { viewModel.toggleTaskCompletion(task, context: viewContext) },
                            onDelete: { viewModel.deleteTask(task, context: viewContext) }
                        )
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    private var floatingAddButton: some View {
        GeometryReader { proxy in
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
                    .presentationDetents([.height(proxy.size.height)])
                    .presentationDragIndicator(.visible)
            }
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
