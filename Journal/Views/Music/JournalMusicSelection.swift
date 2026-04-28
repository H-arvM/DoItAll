//
//  JournalMusicSelection.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/04/2026.
//

import SwiftUI

struct JournalMusicSelection: View {
    let mode: EditOrViewMode
    let track: MusicTrack
    @ObservedObject var viewModel: JournalViewModel
    @ObservedObject var themeManager: ThemeManager
    
    func openTrack(_ track: MusicTrack) {
        let query = "\(track.title) \(track.artist)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let appleMusicURL = URL(string: "music://music.apple.com/search?term=\(query)")!
        if UIApplication.shared.canOpenURL(appleMusicURL) {
            UIApplication.shared.open(appleMusicURL)
            return
        }
        
        let spotifyURL = URL(string: "spotify:search:\(query)")!
        if UIApplication.shared.canOpenURL(spotifyURL) {
            UIApplication.shared.open(spotifyURL)
            return
        }
        
        // Fall back to Apple Music web
        if let webURL = URL(string: "https://music.apple.com/search?term=\(query)") {
            UIApplication.shared.open(webURL)
        }
    }
    
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
                ExpandedMusicView(mode: mode, track: track, viewModel: viewModel, themeManager: themeManager, onPlay: { openTrack(track) })
            } else {
                CollapsedMusicView(track: track, themeManager: themeManager, onPlay: { openTrack(track) })
            }
        }
    }
}
    //
    //#Preview {
    //    JournalMusicSelection()
    //}
