//
//  ListItemHelpers.swift
//  DoItAll
//
//  Created by Marc Harvey on 16/02/2026.
//

import SwiftUI
import Combine

class ListItem: Identifiable, ObservableObject {
    let id = UUID()
    @Published var text: String
    @Published var isCompleted: Bool
    
    init(text: String, isCompleted: Bool = false) {
        self.text = text
        self.isCompleted = isCompleted
    }
}

class ListModel: Identifiable, ObservableObject {
    let id = UUID()
    @Published var title: String
    @Published var items: [ListItem]
    let createdAt: Date
    
    init(title: String, items: [ListItem], createdAt: Date = Date()) {
        self.title = title
        self.items = items
        self.createdAt = createdAt
    }
}

class ListStore: ObservableObject {
    @Published var lists: [ListModel] = []
    
    static let shared = ListStore()
    
    private init() {
//        self.lists = lists
    }
    
    func addList(_ list: ListModel) {
        lists.append(list)
        lists.sort { $0.createdAt > $1.createdAt }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
    }
    
    func deleteList(_ list: ListModel) {
        lists.removeAll { $0.id == list.id }
    }
    
    func createSampleData() -> [ListModel] {
        let groceries = ListModel(title: "Groceries", items: [
            ListItem(text: "Milk"),
            ListItem(text: "Bread"),
            ListItem(text: "Eggs", isCompleted: true)
        ], createdAt: Date())
        
        let todos = ListModel(title: "Work", items: [
            ListItem(text: "Clean garage"),
            ListItem(text: "Mop floor"),
            ListItem(text: "Call Maw", isCompleted: true)
        ])
        return [groceries, todos]
    }
}
