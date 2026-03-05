//
//  NoteSelectionView.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI

struct NoteSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let columns = [ GridItem(.flexible()), GridItem(.flexible())]
    @ObservedObject var settingsManager: SettingsManager
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(NoteTypeTitle.allCases) { noteType in
                        NavigationLink {
                            switch noteType {
                            case .journal:
                                JournalEntryView(context: viewContext, settingsManager: settingsManager)
                            case .shoppingList:
                                ShoppingListEntry()
                            case .scribblePad:
                                ScribbleEntry()
                            case .freeForm:
                                FreeFormView()
                            case .lifeAdmin:
                                LifeAdminView()
                            case .generalList:
                                ListView()
                            }
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: noteType.iconName)
                                    .font(.system(size: geometry.size.width * 0.1))
                                    .foregroundColor(.white)
                                    .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                                    .background(Color.accentColor)
                                    .clipShape(Circle())
                                Text(noteType.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: geometry.size.width * 0.4)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 1)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("New Note")
    }
}

enum NoteTypeTitle: String, CaseIterable, Identifiable {
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
}
