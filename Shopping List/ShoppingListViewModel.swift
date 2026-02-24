//
//  ShoppingListViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI
import Combine
import CoreData

public class ShoppingListViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext

    @Published var itemName: String = ""
    @Published var quantity: String = ""
    @Published var items: [Item] = []

    /// Dictionary grouping items by their shoppingEntryID.
    /// If an item's entry ID is nil, it is grouped by a nil key.
    @Published var groupedItems: [UUID?: [Item]] = [:]
    @Published var currentEntryID: UUID = UUID()

    private var item: Item?

    public init(viewContext: NSManagedObjectContext, item: Item? = nil) {
        self.viewContext = viewContext
        self.item = item
        if let item = item {
            self.itemName = item.shoppingItem ?? ""
            self.quantity = item.shoppingItemQuantity ?? ""
        }
        fetchItems()
    }

    // MARK: - Fetch
    
    /// Fetches shopping items from Core Data and groups them by entry ID.
    func fetchItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "shoppingItem != nil AND shoppingItem != ''")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.shoppingItem, ascending: true)]
        do {
            items = try viewContext.fetch(request)
            groupItemsByEntryID()
        } catch {
            print("Failed to fetch shopping items: \(error)")
        }
    }

    // MARK: - Add
    
    /// Adds a new shopping item to Core Data, assigning the current entry ID,
    /// then refreshes the items and groupedItems.
    func addItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedQty  = quantity.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !trimmedQty.isEmpty else { return }

        let newObject = Item(context: viewContext)
        newObject.shoppingItem = trimmedName
        newObject.shoppingItemQuantity = trimmedQty
        newObject.isChecked = false
        newObject.shoppingEntryID = currentEntryID

        save()

        itemName = ""
        quantity = ""
        fetchItems()
        groupItemsByEntryID()
    }

    // MARK: - Start New Entry
    /// Starts a new shopping entry batch by generating a new entry ID.
    func startNewEntry() {
        currentEntryID = UUID()
    }

    // MARK: - Save (called by toolbar button)

    func saveToCoreData() {
        save()
    }

    // MARK: - Toggle checked state

    func toggleItemChecked(item: Item) {
        item.isChecked.toggle()
        save()
        fetchItems()
    }

    // MARK: - Delete

    func deleteItems(at offsets: IndexSet) {
        offsets.map { items[$0] }.forEach(viewContext.delete)
        save()
        fetchItems()
    }

    // MARK: - Private

    /// Groups the fetched items by their shoppingEntryID.
    /// Items with a nil entry ID are grouped under a nil key.
    private func groupItemsByEntryID() {
        groupedItems = Dictionary(grouping: items) { item in
            item.shoppingEntryID
        }
    }

    private func save() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
