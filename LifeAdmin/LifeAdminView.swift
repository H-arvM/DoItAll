//
//  LifeAdminView.swift
//  DoItAll
//
//  Created by Marc Harvey on 12/02/2026.
//

import SwiftUI

struct LifeAdminView: View {
    @StateObject private var viewModel = LifeAdminViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                contentView
                floatingSettingsButton
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
                            viewModel.toggleTaskCompletion(task)
                        }
                    }
                    .onDelete(perform: viewModel.deleteTask)
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    private var floatingSettingsButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    viewModel.showingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    private var saveButton: some View {
        Button {
            viewModel.saveData()
        } label: {
            Image(systemName: "square.and.arrow.down")
                .font(.body.weight(.medium))
        }
    }
    
    private var addButton: some View {
        Button {
            viewModel.addNewTask()
        } label: {
            Image(systemName: "plus")
                .font(.body.weight(.medium))
        }
    }
}
// MARK: - Task Category Enum
enum TaskCategory: String, CaseIterable {
    case bills = "Bills"
    case medical = "Medical"
    case insurance = "Insurance"
    case taxes = "Taxes"
    case home = "Home"
    case vehicle = "Vehicle"
    case subscriptions = "Subscriptions"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .bills: return "dollarsign.circle.fill"
        case .medical: return "cross.circle.fill"
        case .insurance: return "shield.fill"
        case .taxes: return "doc.text.fill"
        case .home: return "house.fill"
        case .vehicle: return "car.fill"
        case .subscriptions: return "repeat.circle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bills: return .green
        case .medical: return .red
        case .insurance: return .blue
        case .taxes: return .purple
        case .home: return .orange
        case .vehicle: return .cyan
        case .subscriptions: return .pink
        case .other: return .gray
        }
    }
}

// MARK: - Life Admin Task Model
struct LifeAdminTask: Identifiable {
    let id = UUID()
    var title: String
    var category: TaskCategory
    var dueDate: Date
    var isCompleted: Bool
}

// MARK: - Preview
struct LifeAdminView_Previews: PreviewProvider {
    static var previews: some View {
        LifeAdminView()
    }
}
