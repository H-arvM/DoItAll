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
    @StateObject private var viewModel = NoteListViewViewModel()
    @State private var stableItems: [Item] = []

    public var body: some View {
        List {
            let groups = NoteGrouper.groupedByEntryID(stableItems)
            ForEach(groups, id: \.1.first?.objectID) { groupID, groupItems in
                if let _ = groupID, groupItems.count > 1 {
                    Section(header: Text(batchDateString(for: groupItems))) {
                        ForEach(groupItems) { item in
                            noteRowLink(for: item)
                                .frame(height: 75)
                                .id(item.objectID)
                        }
                        .onDelete { offsets in
                            deleteItems(offsets: offsets, from: groupItems)
                        }
                    }
                } else if let item = groupItems.first {
                    noteRowLink(for: item)
                        .frame(height: 75)
                        .id(item.objectID)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationDestination(for: Item.self) { item in
            DisplayEntryView(item: item)
        }
        .alert(
            "Authentication Failed",
            isPresented: $viewModel.showAuthAlert,
            presenting: viewModel.authError
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { error in
            Text(error.localizedDescription)
        }
        .sheet(item: $viewModel.selectedItem) { item in
            DisplayEntryView(item: item)
        }
        .onAppear {
            UserDefaults.standard.removeObject(forKey: "hiddenItemURIs")
            viewModel.loadHiddenItems(context: viewContext)
            if stableItems.isEmpty {
                stableItems = Array(items)
            }
        }
        .onChange(of: items.count) { _ in
            stableItems = Array(items)
        }
    }
    
    @ViewBuilder
    private func noteRowLink(for item: Item) -> some View {
        let isHidden = viewModel.hiddenItems.contains(item.objectID)
        let objectID = item.objectID

        Button {
            if isHidden {
                viewModel.handleHiddenItemTap(item)
            } else {
                viewModel.navigateTo(item)
            }
        } label: {
            noteRow(for: item)
                .contentShape(Rectangle())
                .onLongPressGesture(minimumDuration: 0.5) {
                    viewModel.handleLongPress(for: objectID)
                }
        }
        .buttonStyle(.plain)
        .id(item.objectID)
    }
    
    // MARK: - Row appearance
    @ViewBuilder
    private func noteRow(for item: Item) -> some View {
        let isHidden = viewModel.hiddenItems.contains(item.objectID)

        ZStack {
            if isHidden {
                HiddenIndicatorView {
                    viewModel.handleLongPress(for: item.objectID)
                }
            }
            NavigationArrowView {
                if isHidden {
                    viewModel.handleHiddenItemTap(item)
                } else {
                    viewModel.navigateTo(item)
                }
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .background {
            if isHidden {
                GlassMorphicBackground()
            }
        }
        .overlay(alignment: .bottom) {
            if isHidden {
                Divider()
                    .padding(.leading, 0)
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

    private func noteType(for item: Item) -> NoteType {
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

