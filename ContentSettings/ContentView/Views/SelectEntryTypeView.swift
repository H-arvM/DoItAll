//
//  NoteSelectionView.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI

struct SelectEntryTypeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var navigateToJournal: Bool = false
    @State private var navigateToFreeWriting: Bool = false
    @State private var navigateToShoppingList: Bool = false
    @State private var navigateToLifeAdmin: Bool = false
    @State private var navigateToNotes: Bool = false

    private var entryTypes: [(icon: String, title: String, action: () -> Void)] {
        [
            ("pencil.line", "Journal", { navigateToJournal = true }),
            ("pencil.and.outline", "Free Writing", { navigateToFreeWriting = true }),
            ("cart.fill", "Shopping List", { navigateToShoppingList = true }),
            ("pencil.and.list.clipboard", "Life admin", { navigateToLifeAdmin = true }),
            ("list.clipboard.fill", "Notes", { navigateToNotes = true })
        ]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackgroundView(theme: themeManager.selectedTheme)
                
                ScrollView {
                    VStack(spacing: 20) {
                        let buttonWidth = (UIScreen.main.bounds.width - 60) / 2
                        let rows = entryTypes.chunked(into: 2)
                        
                        ForEach(0..<rows.count, id: \.self) { rowIndex in
                            HStack(spacing: 20) {
                                ForEach(0..<rows[rowIndex].count, id: \.self) { itemIndex in
                                    let item = rows[rowIndex][itemIndex]
                                    
                                    EntryTypeButton(
                                        icon: item.icon,
                                        title: item.title,
                                        colour: themeManager.selectedTheme.primaryColour,
                                        action: item.action
                                    )
                                    .frame(width: buttonWidth)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(themeManager.selectedTheme.primaryColour)
                }
            }
            .navigationDestination(isPresented: $navigateToJournal) {
                JournalView(mode: .edit, entry: nil, initialEntryType: .journal) { dismiss() }
                    .environment(\.managedObjectContext, viewContext)
            }
            .navigationDestination(isPresented: $navigateToFreeWriting) {
                FreeFormView(mode: .edit, entry: nil, initialEntryType: .freeForm) { dismiss() }
                    .environment(\.managedObjectContext, viewContext)
            }
            .navigationDestination(isPresented: $navigateToShoppingList) {
                ShoppingListView(entry: nil, initialEntryType: .shoppingList) { dismiss() }
                    .environment(\.managedObjectContext, viewContext)
            }
            .navigationDestination(isPresented: $navigateToLifeAdmin) {
                LifeAdminView(entry: nil, initialEntryType: .lifeAdmin) { dismiss() }
                    .environment(\.managedObjectContext, viewContext)
            }
            .navigationDestination(isPresented: $navigateToNotes) {
                NoteListView() { dismiss() }
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
