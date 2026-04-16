//
//  FreeFormView.swift
//  DoItAll
//
//  Created by Marc Harvey on 12/02/2026.
//

import SwiftUI

struct FreeFormView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var viewModel: FreeFormViewModel
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    let mode: EditOrViewMode
    var onSave: (() -> Void)?
    
    init(mode: EditOrViewMode = .edit, entry: FreeWritingEntry? = nil, initialEntryType: EntryType = .freeForm, onSave: (() -> Void)? = nil) {
        self.mode = mode
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: FreeFormViewModel(entry: entry, initialEntryType: initialEntryType))
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                textEditorSection
                
                if !viewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    wordCountFooter
                }
            }
        }
        .navigationTitle("Free Form")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.saveFreeform(context: viewContext) {
                        // Crucial: Notify parent BEFORE dismissing or dismissing after save
                        onSave?()
                        dismiss()
                    }
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundStyle(themeManager.selectedTheme.primaryColour)
                }
            }
        }
        .onAppear {
            // Small delay to ensure the keyboard pops up after transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
    
    private var textEditorSection: some View {
        TextEditor(text: $viewModel.content)
            .focused($isTextFieldFocused)
            .font(.body)
            .scrollContentBackground(.hidden)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
    }
    
    private var wordCountFooter: some View {
        HStack {
            Text("\(viewModel.wordCount) words")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .animation(.easeInOut(duration: 0.2), value: viewModel.wordCount)
    }
}

#Preview {
    FreeFormView(mode: .edit, entry: nil, initialEntryType: .freeForm)
}
