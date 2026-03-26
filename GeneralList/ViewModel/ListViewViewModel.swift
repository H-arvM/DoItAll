//
//  ListViewViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 16/02/2026.
//

import SwiftUI

@MainActor
class ListViewViewModel: ObservableObject {
    @Published var listTitle = ""
    @Published var items: [ListItemData] = []
    @Published var currentItemText: String = ""
    @Published var bigSaveButtonTapped: Bool = false
    
    func addItem() {
        let trimmed = currentItemText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            items.append(ListItemData(text: trimmed, isCompleted: false))
            currentItemText = ""
        }
    }
    
    func toggleItem(_ item: ListItemData) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if let index = items.firstIndex(where: { $0.id == item.id}) {
                items[index].isCompleted.toggle()
            }
        }
    }
    
    func deleteItem(_ item: ListItemData) {
        items.removeAll { $0.id == item.id }
    }
    
    func saveList(to listStore: ListStore, dismiss: DismissAction) {
        let newList = ListModel(
            title: listTitle.trimmingCharacters(in: .whitespaces),
            items: items.map { ListItem(text: $0.text, isCompleted: false) }
        )
        
        bigSaveButtonTapped.toggle()
        
        listStore.addList(newList)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            dismiss()
        }
    }
    
    var isSaveDisabled: Bool {
        listTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
