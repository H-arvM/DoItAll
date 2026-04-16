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
    
    var body: some View {
        // 1. Wrap everything in a GeometryReader or use a greedy VStack
        VStack(alignment: .leading, spacing: 8) {
            if mode == .edit {
                ScrollView {
                    TextEditor(text: $viewModel.content)
                        .font(.body)
                        .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(adaptiveBackgroundColour)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(UIColor.separator), lineWidth: 0.5)
                                )
                        )
                        .frame(minHeight: 200, maxHeight: .infinity)
                }
            } else {
                ScrollView {
                    Text(viewModel.content.isEmpty ? "No entry written" : viewModel.content)
                        .font(.body)
                        .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(adaptiveBackgroundColour)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(UIColor.separator), lineWidth: 0.5)
                        )
                )
                .frame(minHeight: 200, maxHeight: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
