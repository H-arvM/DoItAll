//
//  MusicPickerViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 29/03/2026.
//

import Foundation
import MusicKit

@MainActor
final class MusicPickerViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var musicLibrary: MusicLibrary?
    @Published var searchResults: [MusicTrack] = []
    @Published var isSearching = false
    @Published var musicAuthorisationStatus: MusicAuthorization.Status? = .notDetermined
    
    static let searchLimit = 25
    static let artworkSize = 300
    
    func requestAuthorisation() async {
        musicAuthorisationStatus = await MusicAuthorization.request()
    }
    
    func searchMusic(query: String) async {
        guard !query.isEmpty, musicAuthorisationStatus == .authorized else {
            searchResults = []
            return
        }
        
        isSearching = true
        defer  { isSearching = false }
        
        do {
            var request = MusicCatalogSearchRequest(term: query, types: [Song.self])
            request.limit = Self.searchLimit
            let response = try await request.response()
            searchResults = response.songs.compactMap(mapSongToTrack)
        } catch {
            print("Music search error: \(error)")
            searchResults = []
        }
    }
    
    private func mapSongToTrack(_ song: Song) -> MusicTrack? {
        guard let assetURL = song.artwork?.url(width: Self.artworkSize, height: Self.artworkSize) else {
            return nil
        }
        
        return MusicTrack(
            id: song.id.rawValue,
            title: song.title,
            artist: song.artistName,
            artworkURL: assetURL
        )
    }
}
