//
//  JournalEntry.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI
import CoreData
import PhotosUI
import AVFoundation

struct JournalEntry: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: JournalEntryViewModel
    @FocusState private var isJournalTextFocused: Bool
    @State private var showingSettings = false
    @State private var showingActionButtons = false
    @State private var showingMusicPicker = false
    @State private var showingVoiceNoteRecorder = false
    @State private var voiceNoteURL: URL?
    
    @State private var showingFontStylePicker = false
    @State private var fontSize: CGFloat = 18
    @State private var fontColor: Color = .primary
    @State private var fontName: String = "System"
    @State private var fontWeight: Font.Weight = .regular
    @State private var settingsExpanded = false
    
    /// Called after successful save and dismiss. Use this in the presenting view to return to the main ContentView.
    var onSaveAndReturnToRoot: (() -> Void)? = nil
    
    let gridColumns = [GridItem(.adaptive(minimum: 100, maximum: 200), spacing: 10)]
    
    init(context: NSManagedObjectContext, settingsManager: SettingsManager) {
        _viewModel = StateObject(wrappedValue: JournalEntryViewModel(context: context,settingsManager: settingsManager))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom){
                VStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        if viewModel.journalHeader.isEmpty {
                            Text("Enter title")
                                .foregroundColor(Color.gray)
                                .padding(.horizontal, 8)
                        }
                        TextField("", text: $viewModel.journalHeader)
                            .font(.title)
                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                            .background(Color.clear)
                            .submitLabel(.done)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                    isJournalTextFocused = true
                                }
                            }
                    }
                    .frame(height: 50)
                    .padding(.horizontal)
                                        
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 1)
                        .padding(.horizontal)
                    
                    TextEditor(text: $viewModel.journalText)
                        .font(fontForName(fontName, size: fontSize, weight: fontWeight))
                        .foregroundColor(fontColor)
                        .focused($isJournalTextFocused)
                        .frame(maxHeight: .infinity)
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                isJournalTextFocused = true
                            }
                        }
                    
                    if !viewModel.loadedImages.isEmpty {
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(viewModel.loadedImages, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 150)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 160)
                    }
                    
                    if let url = voiceNoteURL {
                        VoiceNotePlayerBar(audioURL: url)
                            .padding([.leading, .trailing, .top], 8)
                    }
                }
                
                // Settings Button - Bottom Left
                Button {
                    showingSettings.toggle()
                } label: {
                    Image(systemName: "gearshape.circle")
                        .font(.system(size: 30))
                        .padding(10)
                        .shadow(radius: 5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(.leading, 20)
                .padding(.bottom, 10)
                
                // Action Buttons - Bottom Right
                VStack(spacing: 15) {
                    if showingActionButtons {
                        PhotosPicker(selection: $viewModel.selectedPhotos, maxSelectionCount: 10, matching: .images) {
                            Image(systemName: "photo.circle")
                                .font(.system(size: 25))
                                .padding(10)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .glassEffect()
                        .padding(.bottom, 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        // Music Picker Button
                        Button {
                            showingMusicPicker.toggle()
                        } label: {
                            Image(systemName: "music.note.square.stack.fill")
                                .font(.system(size: 25))
                                .padding(10)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .glassEffect()
                        .padding(.bottom, 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        // Voice Note Recorder Button
                        Button {
                            showingVoiceNoteRecorder.toggle()
                        } label: {
                            Image(systemName: "mic.circle")
                                .font(.system(size: 25))
                                .padding(10)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .glassEffect()
                        .padding(.bottom, 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    Button {
                        withAnimation {
                            showingActionButtons.toggle()
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 30))
                            .padding(10)
                            .shadow(radius: 5)
                    }
                    .glassEffect()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 20)
                .padding(.bottom, 10)
            }
            
            if viewModel.isShowingEmptyWarning {
                // TODO: Tidy up presenation of this later
                Text("Cannot save empty entry. Fill it out")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .zIndex(2)
                    .padding(.top, 5)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                viewModel.isShowingEmptyWarning = false
                            }
                        }
                    }
                    .transition(.slide)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showingFontStylePicker = true
                } label: {
                    Image(systemName: "pencil.and.scribble")
                }
                
                Button(StringsStore.JournalEntry.saveTitle) {
                    viewModel.saveJournalEntry()
                    if !viewModel.isShowingEmptyWarning {
                        dismiss()
                        onSaveAndReturnToRoot?()
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settingsManager: viewModel.settingsManager, sourceView: "Journal View")
        }
        .sheet(isPresented: $showingMusicPicker) {
            MusicSelectionView(selectedSong: $viewModel.selectedSong)
        }
        .sheet(isPresented: $showingVoiceNoteRecorder) {
            VoiceNoteRecorderView(audioURL: $voiceNoteURL)
        }
        .sheet(isPresented: $showingFontStylePicker) {
            FontStylePickerView(fontSize: $fontSize, fontColor: $fontColor, fontName: $fontName, fontWeight: $fontWeight)
        }
        .task(id: viewModel.selectedPhotos) {
            for photo in viewModel.selectedPhotos {
                if let data = try? await photo.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        viewModel.loadedImages.append(uiImage)
                    }
                }
            }
        }
    }
    
    private func fontForName(_ name: String, size: CGFloat, weight: Font.Weight) -> Font {
        switch name {
        case "Arial": return .custom("Arial", size: size).weight(weight)
        case "Georgia": return .custom("Georgia", size: size).weight(weight)
        case "Courier": return .custom("Courier", size: size).weight(weight)
        default: return .system(size: size, weight: weight)
        }
    }
}

//#Preview {
//    JournalEntry(context: )
//}

