//
//  ListView.swift
//  DoItAll
//
//  Created by Marc Harvey on 16/02/2026.
//

import SwiftUI

struct ListView: View {
    @StateObject private var viewModel = ListViewViewModel()
    @EnvironmentObject var listStore: ListStore
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.97)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                listTitleSection
                
                
                itemsSection
            }
        }
        .navigationTitle("List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    viewModel.saveList(to: listStore, dismiss: dismiss)
                } label: {
                    Image(systemName: "plus.circle")
                        .symbolEffect(.disappear, isActive: viewModel.bigSaveButtonTapped)
                        .foregroundStyle(.blue)
                }
                .disabled(viewModel.isSaveDisabled)
                .fontWeight(.semibold)
            }
        }
    }
    
    private var listTitleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Title")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            TextField("Fave movies, cafes to try...", text: $viewModel.listTitle)
                .font(.subheadline)
                .fontWeight(.semibold)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
    
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 5) {
                Text("Items")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if !viewModel.items.isEmpty {
                    Text("\(viewModel.items.count)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.items) { item in
                        ItemRowView(item: item, onDelete: {
                            viewModel.deleteItem(item)
                        })
                        .id(item.id)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale(scale: 0.01).combined(with: .opacity)
                        ))
                    }
                    
                    addItemSection
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.items.count)
            }
        }
    }
    
    private var addItemSection: some View {
        HStack(spacing: 12) {
            TextField("Wall-E, yer Maw...", text: $viewModel.currentItemText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .textFieldStyle(.plain)
                .focused($isInputFocused)
                .onSubmit {
                    viewModel.addItem()
                }
            
            if !viewModel.currentItemText.isEmpty {
                Button {
                    viewModel.addItem()
                } label: {
                    Image(systemName: "plus.circle")
                        .symbolEffect(.pulse, options: .nonRepeating)
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .frame(height: 50)
    }
}

struct ItemRowView: View {
    let item: ListItemData
    let onDelete: () -> Void
    
    @State private var isDeletingItem: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Text(item.text)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button {
                isDeletingItem.toggle()
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.body)
                    .foregroundStyle(.red)
                    .symbolEffect(.disappear, isActive: isDeletingItem)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .frame(height: 50)
    }
}

struct ListItemData: Identifiable, Equatable {
    let id: UUID = UUID()
    let text: String
    var isCompleted: Bool
    
    static func == (lhs: ListItemData, rhs: ListItemData) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    ListView()
}
