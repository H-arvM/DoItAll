//
//  CollapsedMusicView.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/04/2026.
//

import SwiftUI

struct CollapsedMusicView: View {
    let track: MusicTrack
    @ObservedObject var themeManager: ThemeManager
    let onPlay: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
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
                        .frame(width: 50, height: 50)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
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
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 50, height: 50)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                    .lineLimit(1)
                
                Text(track.artist)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .secondary)
                
            }
            
            Spacer()
            
           Image(systemName: "music.note")
                .font(.caption)
                .foregroundStyle(themeManager.selectedTheme.primaryColour)
        }
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
    }
}

//#Preview("Collapsed Music View") {
//    let mockTrack = MusicTrack(
//        id: "123",
//        title: "Preview Song",
//        artist: "Preview Artist",
//        artworkURL: URL(string: "https://example.com/artwork.jpg")
//    )
//    let themeManager = ThemeManager()
//    let theme = ThemeManager()
//    CollapsedMusicView(track: mockTrack, themeManager: themeManager)
//        .padding()
//        .background(Color(.systemBackground))
//}
