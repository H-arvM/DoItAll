//
//  JournalMusicSelection.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/04/2026.
//

import SwiftUI

struct JournalMusicSelection: View {
    let mode: JournalMode
    let track: MusicTrack
    @ObservedObject var viewModel: JournalViewModel
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.isMusicExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Music")
                        .font(.headline)
                        .foregroundStyle(themeManager.selectedTheme.primaryColour ?? .primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(themeManager.selectedTheme.iconColour)
                        .rotationEffect(.degrees(viewModel.isMusicExpanded ? 0 : -90))
                }
            }
            .buttonStyle(.glass)
            .padding(.horizontal, 20)
            
            if viewModel.isMusicExpanded {
                ExpandedMusicView(mode: mode, track: track, viewModel: viewModel, themeManager: themeManager)
            } else {
                CollapsedMusicView(track: track, themeManager: themeManager)
            }
        }
    }
}
    //
    //#Preview {
    //    JournalMusicSelection()
    //}
