//
//  MusicPickerView.swift
//  DoItAll
//
//  Created by Marc Harvey on 29/03/2026.
//

import SwiftUI
import MusicKit

struct MusicPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MusicPickerViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @Binding var selectedTrack: MusicTrack?
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackgroundView(theme: themeManager.selectedTheme)
                
                VStack {
                    if viewModel.musicAuthorisationStatus != .authorized {
                        AuthorisationRequestView(
                            theme: themeManager.selectedTheme,
                            onRequestAccess: {
                                Task {
                                    await viewModel.requestAuthorisation()
                                }
                            }
                        )
                    } else {
                        MusicSearchList(
                            searchText: $viewModel.searchText,
                            searchResults: viewModel.searchResults,
                            isSearching: viewModel.isSearching,
                            theme: themeManager.selectedTheme,
                            onTrackSelected: { track in
                                selectedTrack = track
                                dismiss()
                            },
                            onSearchTextChanged: { newValue in
                                Task {
                                    await viewModel.searchMusic(query: newValue)
                                }
                            }
                        )
                    }
                }
            }
        }
        .navigationTitle("Add Music")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .task {
            await viewModel.requestAuthorisation()
        }
    }
}

private struct MusicSearchList: View {
    @Binding var searchText: String
    let searchResults: [MusicTrack]
    let isSearching: Bool
    let theme: BackgroundTheme
    let onTrackSelected: (MusicTrack) -> Void
    let onSearchTextChanged: (String) -> Void
    
    var body: some View {
        List {
            ForEach(searchResults, id: \.id) { track in
                TrackRowButton(
                    track: track,
                    theme: theme,
                    onTap: { onTrackSelected(track) }
                )
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search for a song!")
        .onChange(of: searchText) { _, newValue in
            onSearchTextChanged(newValue)
        }
        .overlay {
            EmptyStateMusicView(
                searchResults: searchResults,
                searchText: searchText,
                isSearching: isSearching
            )
        }
    }
}

private struct TrackRowButton: View {
    let track: MusicTrack
    let theme: BackgroundTheme
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                TrackArtwork(
                    artworkURL: track.artworkURL,
                    placeholderColour: theme.primaryColour.opacity(0.2)
                )
                TrackInformation(
                    title: track.title,
                    artist: track.artist,
                    theme: theme
                )
                
                Spacer()
            }
        }
    }
}

private struct TrackArtwork: View {
    let artworkURL: URL?
    let placeholderColour: Color
    
    private let size: CGFloat = 50
    private let cornerRadius: CGFloat = 6
    
    var body: some View {
        if let artworkURL {
            AsyncImage(url: artworkURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(placeholderColour)
            }
            .frame(width: size, height: size)
            clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

private struct TrackInformation: View {
    let title: String
    let artist: String
    let theme: BackgroundTheme
    
    private let titleFont: Font = .headline.bold()
    private let artistFont: Font = .caption
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(titleFont)
                .foregroundColor(theme.primaryTextColour ?? .primary)
            
            Text(artist)
                .font(artistFont)
                .foregroundColor(theme.secondaryTextColour ?? .secondary)
        }
    }
}

private struct EmptyStateMusicView: View {
    let searchResults: [MusicTrack]
    let searchText: String
    let isSearching: Bool
    
    var body: some View {
        Group {
            if searchResults.isEmpty && !searchText.isEmpty && !isSearching {
                ContentUnavailableView.search
            }  else if searchResults.isEmpty && searchText.isEmpty {
                SearchPromptView()
            }
        }
    }
}

private struct SearchPromptView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingGlass")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("Search for music")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Find the perfect song for your journal entry")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    MusicPickerView(selectedTrack: .constant(nil))
}
