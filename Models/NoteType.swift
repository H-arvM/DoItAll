//
//  NoteType.swift
//  DoItAll
//
//  Created by Marc Harvey on 25/03/2026.
//

import Foundation
import SwiftUI

enum ItemType: String, CaseIterable, Identifiable {
    case journalType = "Journal"
    case shoppingListType = "Shopping List"
    case freeFormType = "FreeForm"
    case lifeAdminType = "Life Admin"
    case generalListType = "General List"

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .journalType:
            return "Journal"
        case .shoppingListType:
            return "Shopping List"
        case .freeFormType:
            return "Freeform"
        case .lifeAdminType:
            return "Life Admin"
        case .generalListType:
            return "List"
        }
    }

    var iconName: String {
        switch self {
        case .journalType:
            return "book.fill"
        case .shoppingListType:
            return "cart"
        case .freeFormType:
            return "brain.head.profile"
        case .lifeAdminType:
            return "figure.wave"
        case .generalListType:
            return "list.clipboard"
        }
    }
    
    var colour: Color {
        switch self {
        case .journalType:
            return .blue
        case .shoppingListType:
            return .red
        case .freeFormType:
            return .pink
        case .lifeAdminType:
            return .yellow
        case .generalListType:
            return .orange
        }
    }
}
