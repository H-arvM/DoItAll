//
//  JournalContentSection.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/04/2026.
//

import SwiftUI

struct JournalContentSection: View {
    let mode: JournalMode
    @ObservedObject var viewModel: JournalViewModel
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colourScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if mode == .edit {
                TextEditor(text: $viewModel.content)
                    .font(.body)
                    .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 300)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(adaptiveBackgroundColour)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(UIColor.separator), lineWidth: 0.5)
                            )
                    )
            } else {
                Text(viewModel.content.isEmpty ? "No entry written" : viewModel.content)
                    .font(.body)
                    .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(adaptiveBackgroundColour)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(UIColor.separator), lineWidth: 0.5)
                            )
                    )
            }
        }
        .padding(.horizontal, 20)
    }
    private var adaptiveBackgroundColour: Color {
        colourScheme == .dark ?
        Color(UIColor.secondarySystemBackground)
        : Color(UIColor.systemBackground)
    }
}

#Preview {
    // Minimal preview setup without relying on external helpers like `.mock` or `.constant`.
    // Construct a JournalViewModel with a simple sample entry if needed.
    let sampleViewModel = JournalViewModel()
    sampleViewModel.content = "Sample journal entry..."
    return JournalContentSection(
        mode: .edit,
        viewModel: sampleViewModel,
        themeManager: .shared
    )
}
