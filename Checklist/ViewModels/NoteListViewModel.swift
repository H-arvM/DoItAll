//
//  NoteListViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 22/04/2026.
//

import SwiftUI
import CoreData
import PhotosUI

@MainActor
final class NotesViewModel: ObservableObject, @MainActor HeaderProviderProtocol, @MainActor CoreDataSaveable {
    
    @Published var title: String = ""
    @Published var newItemText: String = ""
    @Published var createdDate: Date = Date()
    @Published var entryType: EntryType = .list

    public var existingEntry: CheckListEntry?

    init(entry: CheckListEntry? = nil, initialEntryType: EntryType = .list) {
        self.existingEntry = entry
        
        if let entry = entry {
            loadExistingEntry(entry)
        } else {
            self.entryType = initialEntryType
        }
    }

    private func loadExistingEntry(_ entry: CheckListEntry) {
        title = entry.title ?? ""
        createdDate = entry.createdAt ?? Date()
        entryType = EntryType(rawValue: entry.entryType ?? "") ?? .list
    }

    
    var sortedItems: [CheckListItem] {
        let set = (existingEntry?.items as? Set<CheckListItem>) ?? []
        return set.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }
    }
    
    func addItem(context: NSManagedObjectContext) {
        guard !newItemText.isEmpty else { return }

        let entry = getOrCreateEntry(in: context)
        self.existingEntry = entry

        let newItem = CheckListItem(context: context)
        newItem.id = UUID()
        newItem.note = newItemText
        newItem.isChecked = false
        newItem.createdAt = Date()
        newItem.items = entry


        entry.title = title.isEmpty ? "New List" : title
        entry.entryType = entryType.rawValue

        do {
            try context.save()
            objectWillChange.send()
            postSaveNotification()
        } catch {
            print("Error saving new item: \(error)")
        }

        newItemText = ""
    }
    func toggleItem(_ item: CheckListItem, context: NSManagedObjectContext) {
        item.isChecked.toggle()
        saveNotesEntry(context: context)
    }

    func deleteItem(_ item: CheckListItem, context: NSManagedObjectContext) {
        context.delete(item)
        saveNotesEntry(context: context)
    }
    
    private func getOrCreateEntry(in context: NSManagedObjectContext) -> CheckListEntry {
        if let existing = existingEntry { return existing }
        
        let entry = CheckListEntry(context: context)
        entry.id = UUID()
        entry.createdAt = createdDate
        entry.entryType = entryType.rawValue
        
        createAssociatedItem(for: entry, in: context)
        return entry
    }
    
    private func createAssociatedItem(for entry: CheckListEntry, in context: NSManagedObjectContext) {
        let item = ItemEntity(context: context)
        item.id = UUID()
        item.title = title.isEmpty ? "New List" : title
        item.createdAt = Date()
        item.type = itemTypeForEntryType(entryType)
        item.checkListEntry = entry
        entry.item = item
    }

    func saveNotesEntry(context: NSManagedObjectContext, onSuccess: (() -> Void)? = nil) {
        let entry = existingEntry ?? getOrCreateEntry(in: context)
        entry.title = title.isEmpty ? "New List" : title
        entry.entryType = entryType.rawValue

        do {
            try context.save()
            existingEntry = entry
            objectWillChange.send()
            postSaveNotification()
            onSuccess?()
        } catch {
            print("Error saving notes list: \(error)")
        }
    }

    private func itemTypeForEntryType(_ entryType: EntryType) -> String {
        switch entryType {
        case .journal: return ItemType.journalType.rawValue
        case .shoppingList: return ItemType.shoppingListType.rawValue
        case .freeForm: return ItemType.freeFormType.rawValue
        case .lifeAdmin: return ItemType.lifeAdminType.rawValue
        case .list: return ItemType.generalNoteType.rawValue
        }
    }

    private func postSaveNotification() {
        NotificationCenter.default.post(name: NSNotification.Name("CheckListEntrySaved"), object: nil)
    }
    
    func save(context: NSManagedObjectContext, completion: @escaping () -> Void) {
        saveNotesEntry(context: context, onSuccess: completion)
    }
}
