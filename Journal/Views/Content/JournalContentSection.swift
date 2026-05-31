//
//  JournalContentSection.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/04/2026.
//

import SwiftUI

struct JournalContentSection: View {
    let mode: EditOrViewMode
    @ObservedObject var viewModel: JournalViewModel
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colourScheme
    @FocusState private var isEditorFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if mode == .edit {
                ScrollView {
                    TextEditor(text: $viewModel.content)
                        .font(.body)
                        .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .frame(minHeight: 400, maxHeight: .infinity)
                        .focused($isEditorFocused)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isEditorFocused = true
                    }
                }
            } else {
                ScrollView {
                    Text(viewModel.content.isEmpty ? "No entry written" : viewModel.content)
                        .font(.body)
                        .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                }
                .frame(minHeight: 400, maxHeight: .infinity)
            }
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
#Preview {
    let sampleViewModel = JournalViewModel()
    sampleViewModel.content = "Sample journal entry..."
    return JournalContentSection(
        mode: .edit,
        viewModel: sampleViewModel,
        themeManager: .shared
    )
}
