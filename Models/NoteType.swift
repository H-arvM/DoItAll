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
    case generalNoteType = "General Note"

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
        case .generalNoteType:
            return "Note"
        }
    }

    var iconName: String {
        switch self {
        case .journalType:
            return "pencil.line"
        case .shoppingListType:
            return "cart"
        case .freeFormType:
            return "brain.head.profile"
        case .lifeAdminType:
            return "figure.wave"
        case .generalNoteType:
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
        case .generalNoteType:
            return .orange
        }
    }
}
