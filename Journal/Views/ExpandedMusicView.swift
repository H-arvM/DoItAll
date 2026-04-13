//
//  ExpandedMusicView.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/04/2026.
//

import SwiftUI

struct ExpandedMusicView: View {
    let mode: JournalMode
    let track: MusicTrack
    @ObservedObject var viewModel: JournalViewModel
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            if let artworkURL = track.artworkURL {
                AsyncImage(url: artworkURL) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle()
                                .fill(themeManager.selectedTheme.primaryColour.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            ProgressView()
                        }
                        .frame(width: 80, height: 80)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        ZStack {
                            Rectangle()
                                .fill(themeManager.selectedTheme.primaryColour.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            Image(systemName: "music.note")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 80, height: 80)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                
                Text(track.artist)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .secondary)
                
            }
            
            Spacer()
            
            if mode == .edit {
                Button {
                    viewModel.selectedTrack = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.selectedTheme.primaryColour.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.separator), lineWidth: 0.5)
            )
        )
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
    }
}

#Preview("ExpandedMusicView") {
    let sampleTrack = MusicTrack(
        id: "sample-id",
        title: "Sample Song",
        artist: "Sample Artist",
        artworkURL: URL(string: "https://example.com/artwork.jpg")
    )
    let vm = JournalViewModel()
    let theme = ThemeManager()
    ExpandedMusicView(
        mode: .edit,
        track: sampleTrack,
        viewModel: vm,
        themeManager: theme
    )
}

