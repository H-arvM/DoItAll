//
//  JournalHeaderSection.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/04/2026.
//

import SwiftUI

protocol HeaderProviderProtocol: ObservableObject {
    var title: String { get set }
    var createdDate: Date { get }
}

struct GenericHeaderSection<T: HeaderProviderProtocol>: View {
    let mode: EditOrViewMode
    @ObservedObject var viewModel: T
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if mode == .edit {
                TextField("Enter title...", text: $viewModel.title)
                    .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                    .font(.system(size: 34, weight: .bold))
                    .textFieldStyle(.plain)
            } else {
                Text(viewModel.title.isEmpty ? "🦄" : viewModel.title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
            }
            
            Text(viewModel.createdDate.formattedDate)
                .font(.subheadline)
                .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .primary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

#Preview {
    let vm = JournalViewModel()
    vm.title = "Consolidated Header"
    return GenericHeaderSection(mode: .edit, viewModel: vm, themeManager: ThemeManager.shared)
}
