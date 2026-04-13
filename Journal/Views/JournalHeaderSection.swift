//
//  JournalHeaderSection.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/04/2026.
//

import SwiftUI

struct JournalHeaderSection: View {
    let mode: JournalMode
    @ObservedObject var viewModel: JournalViewModel
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if mode == .edit {
                TextField("Journal title", text: $viewModel.title)
                    .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                    .font(.system(size: 34, weight: .bold))
                    .textFieldStyle(.plain)
            } else {
                Text(viewModel.title.isEmpty ? "Untitled entry" : viewModel.title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(themeManager.selectedTheme.iconColour)
            }
            
            Text(viewModel.formattedDate)
                .font(.subheadline)
                .foregroundStyle(themeManager.selectedTheme.primaryColour.opacity(0.3))
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

#Preview("Header - Edit Mode") {
    let vm = JournalViewModel()
    vm.title = "My Journal Entry"
    vm.createdDate = Date()
    let theme = ThemeManager()
    return JournalHeaderSection(mode: .edit, viewModel: vm, themeManager: theme)
}

#Preview("Header - View Mode") {
    let vm = JournalViewModel()
    vm.title = "My Journal Entry"
    vm.createdDate = Date()
    let theme = ThemeManager()
    return JournalHeaderSection(mode: .view, viewModel: vm, themeManager: theme)
}
