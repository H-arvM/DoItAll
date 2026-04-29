//
//  Header.swift
//  DoItAll
//
//  Created by Marc Harvey on 29/04/2026.
//

import SwiftUI

struct GenericSingularHeaderSection<T: HeaderProviderProtocol>: View {
    let mode: EditOrViewMode
    @ObservedObject var viewModel: T
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.createdDate.formalFormatString)
                .font(.title2)
                .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .primary)
        }
        .padding(.horizontal, 20)
    }
}

//#Preview {
//    let vm = JournalViewModel()
//    vm.title = "Consolidated Header"
//    GenericSingularHeaderSection(mode: .edit, viewModel: vm, themeManager: ThemeManager.shared)
//}
