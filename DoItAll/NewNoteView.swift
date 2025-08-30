//
//  NewNoteView.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI

struct NewNoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let columns = [ GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(NoteType.allCases) { noteType in
                    NavigationLink {
                        switch noteType {
                        case .journal:
                            JournalEntry(context: viewContext)
                        case .shoppingList:
                            ShoppingListEntry()
                        case .scribblePad:
                            ScribbleEntry()
                        }
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: noteType.iconName)
                                .font(.largeTitle)
                                .imageScale(.large)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                            Text(noteType.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("New Note")
    }
}

enum NoteType: String, CaseIterable, Identifiable {
    case journal, shoppingList, scribblePad

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .journal:
            return "Journal"
        case .shoppingList:
            return "Shopping List"
        case .scribblePad:
            return "Scribble Pad"
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
        }
    }
}
