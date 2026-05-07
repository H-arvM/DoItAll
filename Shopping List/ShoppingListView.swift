//
//  ShoppingListView.swift
//  DoItAll
//

import SwiftUI
import CoreData

enum Field {
    case itemName
    case quantity
}

struct ShoppingListView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var viewModel: ShoppingListViewModel
    @FocusState private var focusedField: Field?
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
        .toolbar {
            toolbarItems
            keyboardNavigation
        }
    }
    
    @ToolbarContentBuilder
        private var keyboardNavigation: some ToolbarContent {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Button(action: { focusedField = .itemName }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .disabled(focusedField == .itemName)

                    Button(action: { focusedField = .quantity }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .disabled(focusedField == .quantity)
                    .padding(.leading, 10)

                    Spacer()
                    
                    Button("Done") {
                        focusedField = nil
                    }
                    .font(.headline)
                }
            }
        }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            CancelButton()
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            if !viewModel.sortedItems.isEmpty {
                SaveButton(
                    viewModel: viewModel,
                    context: viewContext,
                    onSave: onSave ?? { dismiss() }
                )
            }
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
            TextField("Bread/eggs/milk...", text: $viewModel.itemName)
                .focused($focusedField, equals: .itemName)
                .submitLabel(.next)
                .frame(minHeight: 36)
                .padding(.trailing, 12)
                .lineLimit(1)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, 4)
            
            TextField("Qty", text: $viewModel.quantity)
                .focused($focusedField, equals: .quantity)
                .keyboardType(.numberPad)
                .frame(width: 60)
                .padding(.leading, 12)
            
            addItemButton
        }
        .listRowBackground(themeManager.selectedTheme.primaryColour.opacity(0.1))
    }
    
    @ViewBuilder
    private var addItemButton: some View {
        let isInputValid = !viewModel.itemName.isEmpty && !viewModel.quantity.isEmpty
        
        Button {
            viewModel.addItem(context: viewContext)
            focusedField = .itemName
        } label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(isInputValid ? themeManager.selectedTheme.primaryColour : themeManager.selectedTheme.primaryColour.opacity(0.1))
                .font(.title2)
                .scaleEffect(isInputValid ? 1.2 : 1.0)
                .animation(.spring(), value: isInputValid)
        }
        .buttonStyle(BorderlessButtonStyle())
        .disabled(!isInputValid)
    }
    
    private func focusPreviousField() {
        switch focusedField {
        case .quantity: focusedField = .itemName
        default: break
        }
    }
    
    private func focusNextField() {
        switch focusedField {
        case .itemName: focusedField = .quantity
        default: break
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return NavigationView {
        ShoppingListView()
            .environment(\.managedObjectContext, context)
    }
}
