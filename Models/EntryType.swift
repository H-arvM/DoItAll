//
//  Untitled.swift
//  DoItAll
//
//  Created by Marc Harvey on 08/04/2026.
//

import SwiftUI

enum EntryType: String, CaseIterable {
    case journal = "Journal"
    case shoppingList = "Shopping List"
    case freeForm = "Free Form"
    case lifeAdmin = "Life Admin"
    case list = "List"
    
    var iconName: String {
        switch self {
        case .journal: 
            return "pencil.line"
        case .shoppingList:
            return "cart.fill"
        case .freeForm:
            return "brain.head.profile"
        case .lifeAdmin:
            return "person.and.background.striped.horizontal"
        case .list:
            return "list.clipboard"
        }
    }
    
    var colour: Color {
        switch self {
        case .journal:
            return .blue
        case .shoppingList:
            return .red
        case .freeForm:
            return .pink
        case .lifeAdmin:
            return .yellow
        case .list:
            return .orange
        }
    }
}

