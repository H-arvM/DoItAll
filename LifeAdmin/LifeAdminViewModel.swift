//
//  LiveAdminViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 12/02/2026.
//

import SwiftUI

@MainActor
class LifeAdminViewModel: ObservableObject {
    @Published var tasks: [LifeAdminTask] = []
    @Published var selectedCategory: TaskCategory?
    @Published var showingSettings = false
    var filteredTasks: [LifeAdminTask] {
        guard let category = selectedCategory else { return tasks }
        return tasks.filter { $0.category == category }
    }
    
    init() {
        loadSampleData()
    }
    
    func addNewTask() {
        let randomCategory = TaskCategory.allCases.randomElement() ?? .bills
        let newTask = LifeAdminTask(
            title: "New Task",
            category: randomCategory,
            dueDate: Date().addingTimeInterval(86400 * 7),
            isCompleted: false
        )
        
        withAnimation {
            tasks.insert(newTask, at: 0)
        }
    }
    
    func toggleTaskCompletion(_ task: LifeAdminTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        withAnimation {
            tasks[index].isCompleted.toggle()
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        withAnimation {
            if selectedCategory == nil {
                tasks.remove(atOffsets: offsets)
            } else {
                let tasksToDelete = offsets.map { filteredTasks[$0] }
                tasks.removeAll { task in
                    tasksToDelete.contains(where: { $0.id == task.id })
                }
            }
        }
    }
    
    func selectCategory(_ category: TaskCategory) {
        withAnimation(.spring(response: 0.3)) {
            selectedCategory = selectedCategory == category ? nil : category
        }
    }
    
    func saveData() {
        // TODO: Implement CoreData persistence
        print("💾 Saving data to CoreData...")
        print("Tasks saved: \(tasks.count)")
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func loadSampleData() {
        tasks = [
            LifeAdminTask(
                title: "Pay electricity bill",
                category: .bills,
                dueDate: Date().addingTimeInterval(86400 * 3),
                isCompleted: false
            ),
            LifeAdminTask(
                title: "Schedule dentist appointment",
                category: .medical,
                dueDate: Date().addingTimeInterval(86400 * 7),
                isCompleted: false
            ),
            LifeAdminTask(
                title: "Renew car insurance",
                category: .insurance,
                dueDate: Date().addingTimeInterval(86400 * 14),
                isCompleted: false
            ),
            LifeAdminTask(
                title: "File tax documents",
                category: .taxes,
                dueDate: Date().addingTimeInterval(86400 * 30),
                isCompleted: false
            ),
            LifeAdminTask(
                title: "Call plumber for leak",
                category: .home,
                dueDate: Date().addingTimeInterval(86400 * 2),
                isCompleted: false
            ),
        ]
    }
}
