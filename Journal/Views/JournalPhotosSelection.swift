//
//  JournalPhotosSelection.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/04/2026.
//

import SwiftUI

struct JournalPhotosSelection: View {
    let mode: EditOrViewMode
    @ObservedObject var viewModel: JournalViewModel
    @ObservedObject var themeManager: ThemeManager
    
    let isParentExpanded: Bool

    var body: some View {
        Group {
            if isParentExpanded {
                ExpandedPhotosView(viewModel: viewModel, mode: mode)
                    .transition(.opacity)
            } else {
                CollapsedPhotosView(viewModel: viewModel, themeManager: themeManager)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 20)
    }
}

// TODO: Sort later
//#Preview {
//    JournalPhotosSelection()
//}
