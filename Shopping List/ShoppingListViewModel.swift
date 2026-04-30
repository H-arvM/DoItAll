//
//  ShoppingListViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI
import Combine
import CoreData

@MainActor
public class ShoppingListViewModel: ObservableObject, @MainActor CoreDataSaveable {
    @Published var itemName: String = ""
    @Published var quantity: String = ""
    @Published var createdDate: Date = Date()
    
    @Published var entryType: EntryType = .shoppingList
    
    public var existingEntry: ShoppingEntry?
    
    init(entry: ShoppingEntry? = nil, initialEntryType: EntryType = .shoppingList) {
        self.existingEntry = entry
        
        if let entry = entry {
            loadExistingEntry(entry)
        } else {
            self.entryType = initialEntryType
        }
    }
    
    private func loadExistingEntry(_ entry: ShoppingEntry) {
        createdDate = entry.createdDate ?? Date()
        entryType = EntryType(rawValue: entry.entryType ?? "") ?? .shoppingList
    }
    
    var sortedItems: [ShoppingItem] {
        let set = existingEntry?.items as? Set<ShoppingItem> ?? []
        return set.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
    }
    
    func addItem(context: NSManagedObjectContext) {
        guard !itemName.isEmpty else { return }

        let entry = getOrCreateEntry(in: context)
        self.existingEntry = entry  // ← cache it before saveShoppingEntry runs

        let newItem = ShoppingItem(context: context)
        newItem.id = UUID()
        newItem.name = itemName
        newItem.quantity = quantity.isEmpty ? "1" : quantity
        newItem.isChecked = false
        newItem.entry = entry

        saveShoppingEntry(context: context)

        itemName = ""
        quantity = ""
    }
    
    private func getOrCreateEntry(in context: NSManagedObjectContext) -> ShoppingEntry {
        if let existing = existingEntry { return existing }
        
        let entry = ShoppingEntry(context: context)
        entry.id = UUID()
        entry.createdDate = createdDate
        createAssociatedItem(for: entry, in: context)
        return entry
    }
    
    private func createAssociatedItem(for entry: ShoppingEntry, in context: NSManagedObjectContext) {
        let item = ItemEntity(context: context)
        item.id = UUID()
        item.title = "Shopping List"
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
        case .list: return ItemType.generalNoteType.rawValue
        }
    }
    
    func saveShoppingEntry(context: NSManagedObjectContext, onSuccess: (() -> Void)? = nil) {
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
    
    private func postSaveNotification() {
        NotificationCenter.default.post(name: NSNotification.Name("ShoppingEntrySaved"), object: nil)
    }
    
    func save(context: NSManagedObjectContext, completion: @escaping () -> Void) {
        saveShoppingEntry(context: context, onSuccess: completion)
    }
}
