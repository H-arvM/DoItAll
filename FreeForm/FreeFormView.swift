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

    init(mode: EditOrViewMode = .edit, entry: FreeWritingEntry? = nil, initialEntryType: EntryType = .freeForm, onSave: (() -> Void)? = nil) {
        self.mode = mode
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: FreeFormViewModel(entry: entry, initialEntryType: initialEntryType))
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                GenericHeaderSection(mode: mode, viewModel: viewModel, themeManager: themeManager)
                textEditorSection
                
                if !viewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    wordCountFooter
                }
            }
        }
        .navigationTitle("Free Form")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !isViewMode {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.saveFreeform(context: viewContext) {
                            onSave?()
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundStyle(themeManager.selectedTheme.primaryColour)
                    }
                }
            }
        }
        .onAppear {
            if !isViewMode {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextFieldFocused = true
                }
            }
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
