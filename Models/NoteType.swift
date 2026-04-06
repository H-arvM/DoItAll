//
//  NoteType.swift
//  DoItAll
//
//  Created by Marc Harvey on 25/03/2026.
//

import Foundation
import SwiftUI

enum ItemType: String, CaseIterable, Identifiable {
    case journal, shoppingList, scribblePad, freeForm, lifeAdmin, generalList

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .journal:
            return "Journal"
        case .shoppingList:
            return "Shopping List"
        case .scribblePad:
            return "Scribble Pad"
        case .freeForm:
            return "Freeform"
        case .lifeAdmin:
            return "Life Admin"
        case .generalList:
            return "List"
        }
    }

    var iconName: String {
        switch self {
        case .journal:
            return "book.fill"
        case .shoppingList:
            return "list.bullet"
        case .scribblePad:
            return "scribble"
        case .freeForm:
            return "brain.head.profile"
        case .lifeAdmin:
            return "figure.wave"
        case .generalList:
            return "list.clipboard"
        }
    }
    
    var colour: Color {
        switch self {
        case .journal:
            return .blue
        case .shoppingList:
            return .red
        case .scribblePad:
            return .green
        case .freeForm:
            return .pink
        case .lifeAdmin:
            return .yellow
        case .generalList:
            return .orange
        }
    }
    
    var entryType: String {
        switch self {
        case .journal:
            return "Journal"
        case .shoppingList:
            return "Shopping list"
        case .scribblePad:
            return "Scribble pad"
        case .freeForm:
            return "Freeform"
        case .lifeAdmin:
            return "Life Admin"
        case .generalList:
            return "List"
        }
    }
}
