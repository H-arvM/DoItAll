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

    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
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
                            colour: themeManager.selectedTheme.primaryColour
                        ) {
                            navigateToJournal = true
                        }
                        
                        // Free Writing
                        EntryTypeButton(
                            icon: "pencil.and.outline",
                            title: "Free Writing",
                            colour: themeManager.selectedTheme.primaryColour
                        ) {
                            navigateToFreeWriting = true
                        }
                        
                        // Shopping List
                        EntryTypeButton(
                            icon: "cart.fill",
                            title: "Shopping List",
                            colour: themeManager.selectedTheme.primaryColour
                        ) {
                            navigateToShoppingList = true
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Allows user to exit the fullScreenCover without saving
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(themeManager.selectedTheme.primaryColour)
                }
            }
            .background(
                // Using a Group to hold multiple hidden NavigationLinks
                Group {
                    NavigationLink(
                        destination: JournalView(mode: .edit, entry: nil, initialEntryType: .journal) {
                            dismiss()
                        }
                        .environment(\.managedObjectContext, viewContext),
                        isActive: $navigateToJournal
                    ) { EmptyView() }
                    
                    NavigationLink(
                        destination: FreeFormView()
                        .environment(\.managedObjectContext, viewContext),
                        isActive: $navigateToFreeWriting
                    ) { EmptyView() }
                    
                    NavigationLink(
                        destination: LifeAdminView()
                        .environment(\.managedObjectContext, viewContext),
                        isActive: $navigateToShoppingList
                    ) { EmptyView() }
                    
                    NavigationLink(
                        destination: LifeAdminView()
                        .environment(\.managedObjectContext, viewContext),
                        isActive: $navigateToLifeAdmin
                    ) { EmptyView() }
                }
                .hidden()
            )
        }
    }
}
