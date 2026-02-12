//
//  ShoppingListEntry.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI

struct ShoppingListItem: Identifiable {
    let id = UUID()
    var name: String
    var quantity: String
    var isChecked: Bool = false
}

struct ShoppingListEntry: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    @State private var showingSettings = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                List {
                    ForEach(viewModel.items) { item in
                        HStack {
                            Button(action: {
                                viewModel.toggleItemChecked(item: item)
                            }) {
                                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isChecked ? .green : .gray)
                                    .font(.title3)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Text(item.name)
                                .strikethrough(item.isChecked)
                                .lineLimit(2)
                            
                            Spacer()
                            
                            Text("x \(item.quantity)")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: viewModel.deleteItems)
                    
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
                        
                        Button(action: viewModel.addItem) {
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
            
            // Settings Button - Bottom Right
            Button {
                showingSettings.toggle()
            } label: {
                Image(systemName: "gearshape.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                    .padding(10)
                    .shadow(radius: 5)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .navigationTitle("Shopping List")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    viewModel.saveToCoreData()
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            ShoppingListSettingsView()
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NavigationView {
        ShoppingListEntry()
    }
}
