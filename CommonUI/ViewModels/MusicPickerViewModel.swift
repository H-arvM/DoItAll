//
//  MusicPickerViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 29/03/2026.
//

import Foundation
import MusicKit
import UIKit

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
        defer { isSearching = false }
        
        do {
            var request = MusicLibraryRequest<Song>()
            request.limit = 200
            let response = try await request.response()
            let lowercasedQuery = query.lowercased()
            searchResults = response.items
                .filter {
                    $0.title.lowercased().contains(lowercasedQuery) ||
                    $0.artistName.lowercased().contains(lowercasedQuery)
                }
                .prefix(Self.searchLimit)
                .compactMap(mapSongToTrack)
        } catch {
            print("Music search error: \(error)")
            searchResults = []
        }
    }
    
    private func mapSongToTrack(_ song: Song) -> MusicTrack? {
        let artworkURL = song.artwork?.url(width: Self.artworkSize, height: Self.artworkSize)
        return MusicTrack(
            id: song.id.rawValue,
            title: song.title,
            artist: song.artistName,
            artworkURL: artworkURL
        )
    }
    
    func openTrack(_ track: MusicTrack) {
        let query = "\(track.title) \(track.artist)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Try Apple Music first
        let appleMusicURL = URL(string: "music://music.apple.com/search?term=\(query)")!
        if UIApplication.shared.canOpenURL(appleMusicURL) {
            UIApplication.shared.open(appleMusicURL)
            return
        }
        
        // Try Spotify
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
}
