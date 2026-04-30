//
//  FreeFormViewViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 16/02/2026.
//

import SwiftUI
import Combine
import CoreData

class FreeFormViewModel: ObservableObject, @MainActor HeaderProviderProtocol, CoreDataSaveable {
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var createdDate: Date = Date()
    @Published var wordCount: String = ""
    @Published var entryType: EntryType = .freeForm
    
    private var existingEntry: FreeWritingEntry?
    
    init(entry: FreeWritingEntry? = nil, initialEntryType: EntryType = .freeForm) {
        $content
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { text -> String in
                String(text.split(whereSeparator: \.isWhitespace).count)
            }
            .assign(to: &self.$wordCount)
        self.existingEntry = entry
        
        if let entry = entry {
            loadExistingEntry(entry)
        } else {
            self.entryType = initialEntryType
        }
    }
    
    private func loadExistingEntry(_ entry: FreeWritingEntry) {
        title = entry.title ?? ""
        content = entry.content ?? ""
        createdDate = entry.createdDate ?? Date()
        wordCount = entry.wordCount ?? "0"
        entryType = EntryType(rawValue: entry.entryType ?? "") ?? .freeForm
    }
    
    private func getOrCreateEntry(in context: NSManagedObjectContext) -> FreeWritingEntry {
        if let existing = existingEntry {
            return existing
        }
        
        let entry = FreeWritingEntry(context: context)
        entry.id = UUID()
        entry.title = title
        entry.wordCount = wordCount
        entry.createdDate = createdDate
        
        createAssociatedItem(for: entry, in: context)
        
        return entry
    }
    
    private func createAssociatedItem(for entry: FreeWritingEntry, in context: NSManagedObjectContext) {
        let item = ItemEntity(context: context)
        item.id = UUID()
        item.title = title.isEmpty ? "" : title
        item.createdAt = Date()
        item.type = itemTypeForEntryType(entryType)
        item.wordCount = wordCount
        entry.item = item
    }
    
    private func itemTypeForEntryType(_ entryType: EntryType) -> String {
        switch entryType {
        case .journal:
            return ItemType.journalType.rawValue
        case .shoppingList:
            return ItemType.shoppingListType.rawValue
        case .freeForm:
            return ItemType.freeFormType.rawValue
        case .lifeAdmin:
            return ItemType.lifeAdminType.rawValue
        case .list:
            return ItemType.generalNoteType.rawValue
        }
    }
    
    private func updateEntryProperties(_ entry: FreeWritingEntry) {
        entry.title = title.isEmpty ? "Untitled Entry" : title
        entry.content = content
    }
    
    func saveFreeform(context: NSManagedObjectContext, onSuccess: (() -> Void)? = nil) {
        let entry = getOrCreateEntry(in: context)
        updateEntryProperties(entry)
        
        do {
            try context.save()
            existingEntry = entry
            postSaveNotification()
            onSuccess?()
        } catch {
            // TODO: Handle this in a nicer way
            print("Error saving freeform")
        }
    }
    
    private func postSaveNotification() {
        NotificationCenter.default.post(
            name: NSNotification.Name("FreeFormEntrySaved"),
            object: nil
        )
    }
    
    func save(context: NSManagedObjectContext, completion: @escaping () -> Void) {
        saveFreeform(context: context, onSuccess: completion)
    }
    
}
