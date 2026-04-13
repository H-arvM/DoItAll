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
    
    let columns = [ GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            ThemeBackgroundView(theme: themeManager.selectedTheme)
            
            VStack(spacing: 20) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20)
                ], spacing: 20) {
                    // Journal Button
                    EntryTypeButton(
                        icon: "book.fill",
                        title: "Journal",
                        colour: .red
                    ) {
                        navigateToJournal = true
                    }
                    
                    // Free Writing
                    EntryTypeButton(
                        icon: "pencil.and.outline",
                        title: "Free Writing",
                        colour: .red
                    ) {
                        navigateToFreeWriting = true
                    }
                    
                    // Shopping List
                    EntryTypeButton(
                        icon: "cart.fill",
                        title: "Shopping List",
                        colour: .red
                    ) {
                        navigateToShoppingList = true
                    }
                    // TODO: Add in the rest of the entries here
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink(
                destination: JournalView(mode: .edit, entry: nil, initialEntryType: .journal)
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext),
                isActive: $navigateToJournal
            ) {
                JournalView()
            }
                .hidden()
            )
        // TODO: Place others in here and have each entry use the corresponding view with edit mode etc engaged
    }
}

