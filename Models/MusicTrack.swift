//
//  MusicTrack.swift
//  DoItAll
//
//  Created by Marc Harvey on 25/03/2026.
//

import Foundation

struct MusicTrack: Codable, Hashable {
    var id: String
    var title: String
    var artist: String
    var artworkURL: URL?
}
