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

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    
                    PulsingDividerBar()
                        .padding(.vertical, 4)
                    
                    VStack(spacing: 10) {
                        if mode == .edit {
                            newItemInputSection
                        }
                        
                        if !viewModel.sortedItems.isEmpty {
                            listContentSection
                        }
                    }
                    
                    Spacer(minLength: 150)
                }
                .padding(.horizontal, 10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.title.isEmpty ? "New List" : viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems }
    }
    
    // MARK: - New Item Input
    @ViewBuilder
    private var newItemInputSection: some View {
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
        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
    }
    
    // MARK: - List Content
    @ViewBuilder
    private var listContentSection: some View {
        VStack(spacing: 5) {
            ForEach(viewModel.sortedItems) { item in
                HStack(spacing: 0) {
                    ListToggleButton(item: item, context: viewContext, action: viewModel.toggleItem(_:context:))
                        .padding(.trailing, 5)
                    
                    Text(item.note ?? "")
                        .font(.body)
                        .strikethrough(item.isChecked)
                        .foregroundStyle(item.isChecked ? .secondary : .primary)
                    
                    Spacer()
                    
                    if mode == .edit {
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.deleteItem(item, context: viewContext)
                            }
                        } label: {
                            Image(systemName: "trash")
                                .font(.subheadline)
                                .foregroundStyle(.red.opacity(0.7))
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
            }
        }
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
}

#Preview {
    NoteListView()
}

