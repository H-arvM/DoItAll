//
//  MusicSelectionView.swift
//  DoItAll
//
//  Created by Marc Harvey on 14/09/2025.
//

import SwiftUI
import MusicKit

struct MusicSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchTerm: String = ""
    @State private var searchResults: [Song] = []
    @State private var authorizationStatus: MusicAuthorization.Status = .notDetermined

    @Binding var selectedSong: Song?

    var body: some View {
        NavigationStack {
            VStack {
                if authorizationStatus == .authorized {
                    // Search bar and results list
                    List {
                        ForEach(searchResults) { song in
                            Button {
                                selectedSong = song
                                dismiss()
                            } label: {
                                SongResultRow(song: song)
                            }
                            .glassEffect()
                        }
                    }
                    .searchable(text: $searchTerm, placement: .navigationBarDrawer)
                    .onChange(of: searchTerm) { _, newTerm in
                        Task { await performSearch(term: newTerm) }
                    }
                    .onAppear {
                        authorizationStatus = MusicAuthorization.currentStatus
                    }
                } else {
                    // Authorization request view
                    VStack(spacing: 16) {
                        Text("Please authorize Apple Music access.")
                        Button("Authorize") {
                            Task {
                                await MusicAuthorization.request()
                                authorizationStatus = MusicAuthorization.currentStatus
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Add a Song")
        }
    }

    private func performSearch(term: String) async {
        do {
            var searchRequest = MusicCatalogSearchRequest(term: term, types: [Song.self])
            searchRequest.limit = 10
            let searchResponse = try await searchRequest.response()
            searchResults = Array(searchResponse.songs)
        } catch {
            print("Search failed: \(error)")
        }
    }
    
}

// Helper view to display each search result
struct SongResultRow: View {
    let song: Song

    var body: some View {
        HStack {
            if let artwork = song.artwork {
                AsyncImage(url: artwork.url(width: 50, height: 50))
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            }
            VStack(alignment: .leading) {
                Text(song.title).font(.headline)
                Text(song.artistName).font(.subheadline).foregroundColor(.secondary)
            }
        }
    }
}

//#Preview {
//    MusicSelectionView()
//}

