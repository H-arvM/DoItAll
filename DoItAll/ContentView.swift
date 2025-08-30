//
//  ContentView.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.journalText, ascending: true)], animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomLeading) {
                List {
                    ForEach(items) { item in
                        // The destination view now displays the full text of the item.
                        NavigationLink {
                            Text(item.journalText ?? "No text available.")
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.journalText ?? "No text")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                // The list row now shows a snippet of the saved text.
                                Text(item.journalText ?? "No text")
                                    .lineLimit(1) // Prevents the text from taking up too much space
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    // Hamburger Menu Here:
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image(systemName: "slider.vertical.3")
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
                
                // Button to navigate to the new note creation view
                NavigationLink(destination: NewNoteView()) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                        .padding()
                        .shadow(radius: 10)
                }
                .padding(.leading, 10)
                .padding(.bottom, 10)
            }
            .navigationTitle("My Saved Notes")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
