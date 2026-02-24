//
//  NotesListView.swift
//  DoItAll
//
//  Created by Marc Harvey on 06/09/2025.
//

import SwiftUI

public struct NotesListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default
    )
    private var items: FetchedResults<Item>
    @ObservedObject var settingsManager: SettingsManager

    public var body: some View {
        List {
            let groups = NoteGrouper.groupedByEntryID(Array(items))
            ForEach(Array(groups.enumerated()), id: \.offset) { _, group in
                let (groupID, groupItems) = group
                if let _ = groupID, groupItems.count > 1 {
                    Section(header: Text(batchDateString(for: groupItems))) {
                        ForEach(groupItems) { item in
                            NavigationLink { DisplayEntryView(item: item) } label: {
                                noteRow(for: item)
                            }
                            .frame(height: 75)
                        }
                        .onDelete { offsets in
                            deleteItems(offsets: offsets, from: groupItems)
                        }
                    }
                } else if let item = groupItems.first {
                    NavigationLink { DisplayEntryView(item: item) } label: {
                        noteRow(for: item)
                    }
                    .frame(height: 75)
                }
            }
        }
    }

    // MARK: - Helpers
    private func batchDateString(for items: [Item]) -> String {
        guard let date = items.last?.timestamp else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    @ViewBuilder
    private func noteRow(for item: Item) -> some View {
        let type = noteType(for: item)
        
        HStack {
            Image(systemName: type.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.purple)

            if item.isHidden {
                Text("Hidden Entry")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(8)
            } else if !settingsManager.hidePreview {
                Text(item.journalHeader ?? (type == .journal ? StringsStore.ContentView.awrite : type.title))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func noteType(for item: Item) -> NoteTypeTitle {
        if item.shoppingEntryID != nil { return .shoppingList }
        if let text = item.journalText?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            return .journal
        }
        return .generalList
    }

    private func deleteItems(offsets: IndexSet, from groupItems: [Item]) {
        withAnimation {
            offsets.map { groupItems[$0] }.forEach(viewContext.delete)
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

