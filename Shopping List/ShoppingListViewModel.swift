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
    @Published var isChecked: String = ""
    @Published var items: [Item] = []

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
    func fetchItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "shoppingItem != nil AND shoppingItem != ''")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.shoppingItem, ascending: true)]
        do {
            items = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch shopping items: \(error)")
        }
    }

    // MARK: - Add
    func addItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedQty  = quantity.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !trimmedQty.isEmpty else { return }

        let newObject = Item(context: viewContext)
        newObject.shoppingItem = trimmedName
        newObject.shoppingItemQuantity = trimmedQty
        newObject.isChecked = false

        save()

        itemName = ""
        quantity = ""
        fetchItems()
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

    private func save() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
