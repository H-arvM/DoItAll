//
//  JournalPhotosSelection.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/04/2026.
//

import SwiftUI

struct JournalPhotosSelection: View {
    let mode: JournalMode
    @ObservedObject var viewModel: JournalViewModel
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.isPhotosExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Photos")
                        .font(.headline)
                        .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                    
                    Text("\(viewModel.selectedPhotos.count)")
                        .font(.subheadline)
                        .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .secondary)
                        .rotationEffect(.degrees(viewModel.isPhotosExpanded ? 0 : -90))
                }
            }
            .buttonStyle(.glass)
            .padding(.horizontal, 20)
            
            if viewModel.isPhotosExpanded {
                ExpandedPhotosView(mode: mode, viewModel: viewModel)
            } else {
                CollapsedPhotosView(viewModel: viewModel, themeManager: themeManager)
            }
        }
    }
}

// TODO: Sort later
//#Preview {
//    JournalPhotosSelection()
//}
