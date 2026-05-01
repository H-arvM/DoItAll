//
//  NoteListView.swift
//  DoItAll
//
//  Created by Marc Harvey on 22/04/2026.
//

import SwiftUI

struct NoteListView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var viewModel: NotesViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let mode: EditOrViewMode
    var onSave: (() -> Void)?
    
    init(mode: EditOrViewMode = .edit, entry: CheckListEntry? = nil, onSave: (() -> Void)? = nil) {
        self.mode = mode
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: NotesViewModel(entry: entry, initialEntryType: .list))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ThemeBackgroundView(theme: themeManager.selectedTheme)
                .ignoresSafeArea()
            
            List {
                Group {
                    headerSection
                    
                    PulsingDividerBar()
                        .padding(.vertical, 4)
                    
                    if mode == .edit {
                        itemInputSection
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(themeManager.selectedTheme.primaryColour.opacity(0.1))
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16))
                
                listContentSection
                
               
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.title.isEmpty ? "New List" : viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        GenericHeaderMultiSection(mode: mode, viewModel: viewModel, themeManager: themeManager)
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if mode == .edit {
                CancelButton()
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            SaveButton(
                viewModel: viewModel,
                context: viewContext,
                onSave: onSave ?? { dismiss() }
            )
        }
    }
    
    @ViewBuilder
    private var itemInputSection: some View {
        HStack {
            TextField("Add an item...", text: $viewModel.newItemText)
                .textFieldStyle(.plain)
            
            Button {
                withAnimation {
                    viewModel.addItem(context: viewContext)
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(themeManager.selectedTheme.primaryColour)
            }
            .disabled(viewModel.newItemText.isEmpty)
        }
        .padding()
        .background(themeManager.selectedTheme.primaryColour.opacity(0.1))
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private var listContentSection: some View {
        ForEach(viewModel.sortedItems) { item in
            HStack(spacing: 12) {
                ListToggleButton(item: item, context: viewContext, action: viewModel.toggleItem(_:context:))
                
                Text(item.note ?? "")
                    .font(.body)
                    .strikethrough(item.isChecked)
                    .foregroundStyle(item.isChecked ? .secondary : .primary)
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .frame(minHeight: 60)
            .background(themeManager.selectedTheme.primaryColour.opacity(0.1))
            .cornerRadius(12)
            .listRowSeparator(.hidden)
            .listRowBackground(themeManager.selectedTheme.primaryColour.opacity(0.1))
            .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                if mode == .edit {
                    Button(role: .destructive) {
                        viewModel.deleteItem(item, context: viewContext)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}

#Preview {
    NoteListView()
}
