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
    
    private var isViewMode: Bool { mode == .view }

    init(mode: EditOrViewMode = .edit,
         entry: FreeWritingEntry? = nil,
         initialEntryType: EntryType = .freeForm,
         onSave: (() -> Void)? = nil) {
        self.mode = mode
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: FreeFormViewModel(entry: entry, initialEntryType: initialEntryType))
    }
    
    var body: some View {
        ZStack {
            ThemeBackgroundView(theme: themeManager.selectedTheme)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                GenericHeaderMultiSection(
                    mode: mode,
                    viewModel: viewModel,
                    themeManager: themeManager
                )
                .padding(.horizontal, 20)
                
                PulsingDividerBar()
                    .padding(.vertical, 4)
                    .padding(.horizontal, 20)
                
                textEditorSection
                
                if !viewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    wordCountFooter
                }
            }
        }
        .navigationBarBackButtonHidden(mode == .edit)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems }
        .onAppear {
            if !isViewMode {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextFieldFocused = true
                }
            }
        }
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
    
    private var textEditorSection: some View {
        TextEditor(text: $viewModel.content)
            .focused($isTextFieldFocused)
            .disabled(isViewMode)
            .font(.body)
            .scrollContentBackground(.hidden)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
    }
    
    private var wordCountFooter: some View {
        HStack {
            Text("\(viewModel.wordCount) \(viewModel.wordCount == "1" ? "word" : "words")")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
        .animation(.easeInOut(duration: 0.2), value: viewModel.wordCount)
    }
}

#Preview {
    FreeFormView(mode: .edit, entry: nil, initialEntryType: .freeForm)
}
