//  VoiceNotePlayerBar.swift
//  DoItAll
//
//  Created by Assistant on 11/02/2026.
//

import SwiftUI
import AVFoundation

struct VoiceNotePlayerBar: View {
    let audioURL: URL
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var showingError = false

    var body: some View {
        HStack(spacing: 16) {
            Button(action: togglePlay) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 28))
            }
            Text(isPlaying ? "Playing..." : "Voice Note")
                .font(.subheadline)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
        .onDisappear { player?.stop() }
        .alert("Playback failed", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        }
    }

    private func togglePlay() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            do {
                player = try AVAudioPlayer(contentsOf: audioURL)
                player?.play()
                isPlaying = true
            } catch {
                showingError = true
            }
        }
    }
}
