//
//  ToggleButton.swift
//  DoItAll
//
//  Created by Marc Harvey on 29/04/2026.
//

import SwiftUI
import CoreData

protocol CoreDataToggleable: ObservableObject {
    var isChecked: Bool { get }
}

struct ListToggleButton<Item: CoreDataToggleable & ObservableObject>: View {
    
    @ObservedObject var item: Item
    let context: NSManagedObjectContext
    let action: (Item, NSManagedObjectContext) -> Void
    
    @StateObject private var themeManager = ThemeManager.shared

    // MARK: - Body
    var body: some View {
        Button {
            withAnimation(.snappy) {
                action(item, context)
            }
        } label: {
            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(item.isChecked ? .green : .gray)
        }
    }
}

extension CheckListItem: CoreDataToggleable { }

//#Preview {
//    ToggleButton()
//}
