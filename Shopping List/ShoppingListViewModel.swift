//
//  ShoppingListViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI
import Combine

public class ShoppingListViewModel: ObservableObject {
    @Published var items: [ShoppingListItem] = []
    @Published var itemName: String = ""
    @Published var quantity: String = ""
    
    func addItem() {
        guard !itemName.isEmpty, !quantity.isEmpty else { return }
        
        let newItem = ShoppingListItem(
            name: itemName,
            quantity: quantity
        )
        items.append(newItem)
        
        // Clear fields after adding
        itemName = ""
        quantity = ""
    }
    
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func toggleItemChecked(item: ShoppingListItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isChecked.toggle()
        }
    }
    
    func saveToCoreData() {
        // Placeholder for CoreData save functionality
        print("Saving to CoreData...")
        print("Items to save: \(items.count)")
    }
}
