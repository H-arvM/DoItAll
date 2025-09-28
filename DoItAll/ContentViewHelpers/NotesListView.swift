//
//  NotesListView.swift
//  DoItAll
//
//  Created by Marc Harvey on 06/09/2025.
//

import SwiftUI

public struct NotesListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)], animation: .default)
    private var items: FetchedResults<Item>
    @ObservedObject var settingsManager: SettingsManager

    public var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink {
                    DisplayEntryView(item: item)
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            // TODO: Add back in later and make it prettier. Theres value in having the timestamp and will need formatting too
                            //                        Text(item.timestamp!, formatter: itemFormatter)
                            //                            .font(.footnote)
                            //                            .foregroundColor(.gray)
                            
                            Image(systemName: getIconName(for: item))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.purple)
                            
                            // Check if the item is hidden first
                            if item.isHidden {
                                Text("Hidden Entry")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(8)
                            } else if !settingsManager.hidePreview {
                                Text(item.journalHeader ?? StringsStore.ContentView.awrite)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .frame(height: 75)
            }
            .onDelete(perform: deleteItems)
        }
    }
    
    private func getIconName(for item: Item) -> String {
        // TODO: Expand for other entry types
        let hasText = (item.journalText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        
        if hasText { return NoteType.journal.iconName }
        
       
        return NoteType.journal.iconName
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

//#Preview {
//    NotesListView()
//}
