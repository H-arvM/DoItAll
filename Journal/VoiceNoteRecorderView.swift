//  VoiceNoteRecorderView.swift
//  DoItAll
//
//  Created by Assistant on 11/02/2026.
//

import SwiftUI
import AVFoundation

struct VoiceNoteRecorderView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var audioURL: URL?
    
    @State private var recording = false
    @State private var player: AVAudioPlayer?
    @State private var audioRecorder: AVAudioRecorder?
    @State private var currentRecordingURL: URL?
    @State private var showingPlaybackError = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Voice Note")
                .font(.title2)
                .padding(.top)

            if let url = currentRecordingURL ?? audioURL {
                HStack(spacing: 24) {
                    Button(action: play) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 40))
                    }
                    Button(action: stopPlayback) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 40))
                    }
                }
            }

            Button(action: recording ? stopRecording : startRecording) {
                HStack {
                    Image(systemName: recording ? "stop.fill" : "record.circle")
                        .foregroundColor(recording ? .red : .accentColor)
                        .font(.system(size: 30))
                    Text(recording ? "Stop Recording" : "Start Recording")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .shadow(radius: 3)
            }
            .disabled(recording && audioRecorder == nil)
            
            if let url = currentRecordingURL ?? audioURL {
                Button("Attach Voice Note") {
                    audioURL = url
                    dismiss()
                }
                .padding(.top)
            }

            Spacer()
        }
        .padding()
        .alert("Playback error", isPresented: $showingPlaybackError) {
            Button("OK", role: .cancel) {}
        }
    }
    
    // MARK: - Recording
    private func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("voiceNote_\(UUID().uuidString).m4a")
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            currentRecordingURL = url
            recording = true
        } catch {
            recording = false
        }
    }
    private func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        recording = false
    }
    // MARK: - Playback
    private func play() {
        guard let url = currentRecordingURL ?? audioURL else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            showingPlaybackError = true
        }
    }
    private func stopPlayback() {
        player?.stop()
    }
}

