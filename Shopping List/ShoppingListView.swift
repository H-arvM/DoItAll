//
//  ShoppingListView.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI
import CoreData

struct ShoppingListView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var viewModel: ShoppingListViewModel
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    var onSave: (() -> Void)?

    init(entry: ShoppingEntry? = nil, initialEntryType: EntryType = .freeForm, onSave: (() -> Void)? = nil) {
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: ShoppingListViewModel(entry: entry, initialEntryType: initialEntryType))
    }
    
    var body: some View {
        ZStack {
            ThemeBackgroundView(theme: themeManager.selectedTheme)
                .ignoresSafeArea()
            
            VStack {
                List {
                    addItemRow
                    itemRows
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarItems }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            CancelButton()
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            SaveButton(
                viewModel: viewModel,
                context: viewContext,
                onSave: onSave ?? { dismiss() }
            )
        }
    }

    @ViewBuilder
    private var itemRows: some View {
        ForEach(viewModel.sortedItems, id: \.objectID) { item in
            itemRow(for: item)
                .listRowBackground(themeManager.selectedTheme.primaryColour.opacity(0.1))
        }
        .onDelete { indexSet in
            indexSet.map { viewModel.sortedItems[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }

    @ViewBuilder
    private func itemRow(for item: ShoppingItem) -> some View {
        HStack {
            checkmarkButton(for: item)

            Text(item.name ?? "New Item")
                .strikethrough(item.isChecked)
                .lineLimit(2)

            Spacer()

            Text("x \(item.quantity ?? "1")")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func checkmarkButton(for item: ShoppingItem) -> some View {
        Button {
            item.isChecked.toggle()
            try? viewContext.save()
        } label: {
            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(item.isChecked ? .green : .gray)
                .font(.title3)
        }
        .buttonStyle(BorderlessButtonStyle())
    }

    @ViewBuilder
    private var addItemRow: some View {
        HStack(alignment: .center, spacing: 0) {
            TextField("Item name", text: $viewModel.itemName, axis: .vertical)
                .lineLimit(2)
                .frame(minHeight: 36)
                .padding(.trailing, 12)

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, 4)

            TextField("Qty", text: $viewModel.quantity)
                .keyboardType(.numberPad)
                .frame(width: 60)
                .padding(.leading, 12)

            addItemButton
        }
        .listRowSeparator(.hidden)
        .listRowBackground(themeManager.selectedTheme.primaryColour.opacity(0.1))
    }

    @ViewBuilder
    private var addItemButton: some View {
        Button {
            viewModel.addItem(context: viewContext)
        } label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.blue)
                .font(.title2)
        }
        .buttonStyle(BorderlessButtonStyle())
        .disabled(viewModel.itemName.isEmpty || viewModel.quantity.isEmpty)
        .padding(.leading, 8)
    }
}
#Preview {
    let context = PersistenceController.preview.container.viewContext
    return NavigationView {
        ShoppingListView()
            .environment(\.managedObjectContext, context)
    }
}
