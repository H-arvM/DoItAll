//
//  LiveAdminViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 12/02/2026.
//

import SwiftUI
import CoreData

@MainActor
class LifeAdminViewModel: ObservableObject, @MainActor CoreDataSaveable {
    
    // MARK: - Properties
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
    @Published var entryID: UUID?

    public var existingEntry: TaskEntry?

    var filteredTasks: [TaskItem] {
        guard let category = selectedCategory else { return tasks }
        return tasks.filter { $0.category == category.rawValue }
    }

    // MARK: - Initialization
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
        entryID = entry.id
    }

    // MARK: - Task Management
    func loadTasks(context: NSManagedObjectContext) {
        guard let entry = existingEntry, let id = entry.id else { return }

        // Ensure we have the freshest data if changed elsewhere
        context.refresh(entry, mergeChanges: true)

        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        request.predicate = NSPredicate(format: "taskEntry.id == %@", id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskItem.sortOrder, ascending: true)]

        do {
            self.tasks = try context.fetch(request)
        } catch {
            print("❌ Fetch failed: \(error)")
        }
    }

    func addTask(context: NSManagedObjectContext) {
        guard !itemName.isEmpty else { return }
        
        let entry = getOrCreateEntry(in: context)
        
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
        
        // Save locally for the new task
        saveContext(context)
        loadTasks(context: context)
        
        // UI Reset
        resetForm()
    }

    func toggleTaskCompletion(_ task: TaskItem, context: NSManagedObjectContext) {
        task.isCompleted.toggle()
        saveContext(context)
    }

    func deleteTask(_ task: TaskItem, context: NSManagedObjectContext) {
        context.delete(task)
        saveContext(context)
        loadTasks(context: context)
    }

    func selectCategory(_ category: TaskCategory) {
        withAnimation(.spring(response: 0.3)) {
            selectedCategory = selectedCategory == category ? nil : category
        }
    }

    // MARK: - Save & Entry Persistence

    /// Matches the call site in LifeAdminView: saveAdminEntry(context:onSuccess:)
    @discardableResult
    func saveAdminEntry(context: NSManagedObjectContext, onSuccess: (() -> Void)? = nil) -> UUID? {
        let entry = getOrCreateEntry(in: context)
        entry.entryType = entryType.rawValue

        do {
            try context.save()
            self.existingEntry = entry
            self.entryID = entry.id
            
            postSaveNotification()
            onSuccess?()
            return entry.id
        } catch {
            print("❌ Error saving admin entry: \(error)")
            return nil
        }
    }

    private func getOrCreateEntry(in context: NSManagedObjectContext) -> TaskEntry {
        if let existing = existingEntry { return existing }
        
        let entry = TaskEntry(context: context)
        entry.id = UUID()
        entry.createdAt = createdDate
        entry.entryType = entryType.rawValue
        
        createAssociatedItem(for: entry, in: context)
        
        self.existingEntry = entry
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

    // MARK: - Helpers
    private func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            try? context.save()
            objectWillChange.send()
        }
    }

    private func resetForm() {
        itemName = ""
        notes = ""
        dueDate = nil
        hasDueDate = false
        showingAddTask = false
    }

    private func fetchCategorySettings(for category: TaskCategory, context: NSManagedObjectContext) -> CategorySettings? {
        let request: NSFetchRequest<CategorySettings> = CategorySettings.fetchRequest()
        request.predicate = NSPredicate(format: "categoryRawValue == %@", category.rawValue)
        request.fetchLimit = 1
        return try? context.fetch(request).first
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
        NotificationCenter.default.post(name: NSNotification.Name("LifeAdminEntrySaved"), object: nil)
    }
    
    func save(context: NSManagedObjectContext, completion: @escaping () -> Void) {
        saveAdminEntry(context: context, onSuccess: completion)
    }
}
