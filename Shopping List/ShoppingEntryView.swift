//
//  ShoppingListEntry.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI
import CoreData

struct ShoppingEntryView: View {
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
        ZStack(alignment: .bottomTrailing) {
            VStack {
                List {
                    // Use non-binding ForEach — Item is a reference type (NSManagedObject)
                    // so mutations are reflected without needing a Binding.
                    ForEach(viewModel.sortedItems, id: \.objectID) { item in
                        HStack {
                            Button(action: {
                                item.isChecked.toggle()
                                try? viewContext.save()
                            }) {
                                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isChecked ? .green : .gray)
                                    .font(.title3)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Text(item.name ?? "New Item")
                                .strikethrough(item.isChecked)
                                .lineLimit(2)
                            
                            Spacer()
                            
                          
                            Text("x \(item.quantity ?? "1")")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete { indexSet in
                        indexSet.map { viewModel.sortedItems[$0] }.forEach(viewContext.delete)
                        try? viewContext.save()
                    }
                    
                    // Add item row
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
                        
                        Button(action: {
                            viewModel.addItem(context: viewContext)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(viewModel.itemName.isEmpty || viewModel.quantity.isEmpty)
                        .padding(.leading, 8)
                    }
                    .listRowSeparator(.hidden)
                }
            }
        }
        .navigationTitle("Shopping List")
        .toolbar { toolbarItems }
    }
    
    private var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                viewModel.saveShoppingEntry(context: viewContext) {
                if let onSave = onSave {
                        onSave()
                    } else {
                        dismiss()
                    }
                }
            } label: {
                Image(systemName: "square.and.arrow.down")
                    .foregroundStyle(themeManager.selectedTheme.primaryColour)
            }
        }
    }

}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return NavigationView {
        ShoppingEntryView()
            .environment(\.managedObjectContext, context)
    }
}
