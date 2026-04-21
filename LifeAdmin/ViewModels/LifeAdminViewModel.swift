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
    @Published var tasks: [TaskItem] = []
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

    var filteredTasks: [TaskItem] {
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

    func loadTasks(context: NSManagedObjectContext) {
        guard let entry = existingEntry else {
            print("⚠️ Load aborted: No entry present.")
            return
        }

        context.refresh(entry, mergeChanges: true)

        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        request.predicate = NSPredicate(format: "taskEntry.id == %@", entry.id! as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskItem.sortOrder, ascending: true)]

        do {
            let fetched = try context.fetch(request)
            self.tasks = fetched
            print("📍 Current ID: \(entry.id?.uuidString ?? "NIL") | Tasks: \(fetched.count)")
        } catch {
            print("❌ Fetch failed: \(error)")
        }
    }

    func addTask(context: NSManagedObjectContext) {
        print("Add Task called with name: \(itemName)")
        guard !itemName.isEmpty else {
            print("Item name was empty, exiting.")
            return
        }
        
        let entry = existingEntry ?? getOrCreateEntry(in: context)
        
        let newTask = TaskItem(context: context)
        newTask.id = UUID()
        newTask.title = itemName
        newTask.notes = notes.isEmpty ? nil : notes
        newTask.category = selectedCategory?.rawValue
        newTask.createdAt = Date()
        newTask.isCompleted = false
        newTask.sortOrder = Int32(tasks.count)
        newTask.dueDate = hasDueDate ? dueDate : nil
        newTask.taskEntry = entry
        
        if let category = selectedCategory {
            newTask.categoryEntry = fetchCategorySettings(for: category, context: context)
        }
        
        do {
            try context.save()
            print("✅ Save successful!")
        } catch {
            let nsError = error as NSError
            print("❌ Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        loadTasks(context: context)
        
        itemName = ""
        notes = ""
        dueDate = nil
        hasDueDate = false
        showingAddTask = false
    }
    
    func toggleTaskCompletion(_ task: TaskItem, context: NSManagedObjectContext) {
        task.isCompleted.toggle()
        saveAdminEntry(context: context)
    }

    func deleteTask(_ task: TaskItem, context: NSManagedObjectContext) {
        context.delete(task)
        do {
            try context.save()
        } catch {
            print("Failed to delete task: \(error)")
        }
        loadTasks(context: context)
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
            print("Error saving admin entry: \(error)")
        }
    }
    
    private func getOrCreateEntry(in context: NSManagedObjectContext) -> TaskEntry {
        if let existing = existingEntry { return existing }
        
        let entry = TaskEntry(context: context)
        entry.id = UUID()
        entry.createdAt = createdDate
        entry.entryType = entryType.rawValue
        createAssociatedItem(for: entry, in: context)
        existingEntry = entry
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
