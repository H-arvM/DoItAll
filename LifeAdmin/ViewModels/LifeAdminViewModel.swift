//
//  LiveAdminViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 12/02/2026.
//

import SwiftUI
import CoreData

@MainActor
class LifeAdminViewModel: ObservableObject {
    @Published var tasks: [TaskEntry] = []
    @Published var selectedCategory: TaskCategory?
    @Published var showingSettings = false
    @Published var createdDate: Date = Date()
    @Published var entryType: EntryType = .lifeAdmin
    @Published var itemName: String = ""
    @Published var notes: String = ""
    @Published var showingAddTask = false
    @Published var hasDueDate: Bool = false
    @Published var dueDate: Date? = nil

    public var existingEntry: TaskEntry?

    var filteredTasks: [TaskEntry] {
        guard let category = selectedCategory else { return tasks }
        return tasks.filter { $0.category == category.rawValue }
    }

    init(entry: TaskEntry? = nil, initialEntryType: EntryType = .lifeAdmin) {
        self.existingEntry = entry
        if let entry = entry {
            loadExistingEntry(entry)
        } else {
            self.entryType = initialEntryType
        }
    }

    private func loadExistingEntry(_ entry: TaskEntry) {
        createdDate = entry.createdAt ?? Date()
        entryType = EntryType(rawValue: entry.entryType ?? "") ?? .lifeAdmin
    }

    // MARK: - Fetch

    func loadTasks(context: NSManagedObjectContext) {
        let request: NSFetchRequest<TaskEntry> = TaskEntry.fetchRequest()
        request.predicate = NSPredicate(format: "entryType == %@", EntryType.lifeAdmin.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskEntry.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \TaskEntry.createdAt, ascending: false)
        ]
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Failed to fetch tasks: \(error)")
        }
    }

    func addTask(context: NSManagedObjectContext) {
        guard !itemName.isEmpty else { return }

        let newTask = TaskEntry(context: context)
        newTask.id = UUID()
        newTask.title = itemName
        newTask.notes = notes.isEmpty ? nil : notes
        newTask.category = selectedCategory?.rawValue
        newTask.entryType = entryType.rawValue
        newTask.createdAt = Date()
        newTask.isCompleted = false
        newTask.sortOrder = Int32(tasks.count)
        newTask.dueDate = hasDueDate ? dueDate : nil  // ← new

        if let category = selectedCategory {
            newTask.taskEntry = fetchCategorySettings(for: category, context: context)
        }
        
        // Reset
        itemName = ""
        notes = ""
        dueDate = nil
        hasDueDate = false
        showingAddTask = false
    }

    func toggleTaskCompletion(_ task: TaskEntry, context: NSManagedObjectContext) {
        task.isCompleted.toggle()
        saveAdminEntry(context: context)
    }

    func deleteTask(at offsets: IndexSet, context: NSManagedObjectContext) {
        offsets.map { filteredTasks[$0] }.forEach { context.delete($0) }
        saveAdminEntry(context: context)
    }

    func selectCategory(_ category: TaskCategory) {
        withAnimation(.spring(response: 0.3)) {
            selectedCategory = selectedCategory == category ? nil : category
        }
    }

    private func fetchCategorySettings(
        for category: TaskCategory,
        context: NSManagedObjectContext
    ) -> CategorySettings? {
        let request: NSFetchRequest<CategorySettings> = CategorySettings.fetchRequest()
        request.predicate = NSPredicate(format: "categoryRawValue == %@", category.rawValue)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    // MARK: - Save
    
    func saveAdminEntry(context: NSManagedObjectContext, onSuccess: (() -> Void)? = nil) {
        let entry = existingEntry ?? getOrCreateEntry(in: context)
        entry.entryType = entryType.rawValue

        do {
            try context.save()
            existingEntry = entry
            objectWillChange.send()
            postSaveNotification()
            onSuccess?()
        } catch {
            print("Error saving shopping list: \(error)")
        }
    }
    
    private func getOrCreateEntry(in context: NSManagedObjectContext) -> TaskEntry {
        if let existing = existingEntry { return existing }
        
        let entry = TaskEntry(context: context)
        entry.id = UUID()
        entry.createdAt = createdDate
        createAssociatedItem(for: entry, in: context)
        return entry
    }
    
    private func createAssociatedItem(for entry: TaskEntry, in context: NSManagedObjectContext) {
        let item = ItemEntity(context: context)
        item.id = UUID()
        item.title = "Admin"
        item.createdAt = Date()
        item.type = itemTypeForEntryType(entryType)
        entry.item = item
    }
    
    private func itemTypeForEntryType(_ entryType: EntryType) -> String {
        switch entryType {
        case .journal: return ItemType.journalType.rawValue
        case .shoppingList: return ItemType.shoppingListType.rawValue
        case .freeForm: return ItemType.freeFormType.rawValue
        case .lifeAdmin: return ItemType.lifeAdminType.rawValue
        case .list: return ItemType.generalListType.rawValue
        }
    }
    
    private func postSaveNotification() {
        NotificationCenter.default.post(
            name: NSNotification.Name("LifeAdminEntrySaved"),
            object: nil
        )
    }
}
