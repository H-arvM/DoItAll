//
//  JournalEntry.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI
import CoreData
import PhotosUI

struct JournalEntry: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: JournalEntryViewModel
    @FocusState private var isJournalTextFocused: Bool
    @State private var showingSettings = false
    @State private var showingActionButtons = false
    @State private var showingMusicPicker = false
    
    let gridColumns = [GridItem(.adaptive(minimum: 100, maximum: 200), spacing: 10)]
    
    init(context: NSManagedObjectContext, settingsManager: SettingsManager) {
        _viewModel = StateObject(wrappedValue: JournalEntryViewModel(context: context,settingsManager: settingsManager))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom){
                VStack(spacing: 0) {
                    TextEditor(text: $viewModel.journalText)
                        .focused($isJournalTextFocused)
                        .frame(maxHeight: .infinity)
                        .padding()
                        .border(Color.gray, width: 1)
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
                }
                
                // Settings Button
                Button {
                    showingSettings.toggle()
                } label: {
                    Image(systemName: "gearshape.circle")
                        .font(.system(size: 40))
                        .padding(10)
                }
                .glassEffect()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(.leading, 10)
                .padding(.bottom, 10)
                                
                HStack(spacing: 15) {
                    if showingActionButtons {
                        PhotosPicker(selection: $viewModel.selectedPhotos, maxSelectionCount: 10, matching: .images) {
                            Image(systemName: "photo.circle")
                                .font(.system(size: 25))
                                .padding(10)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .glassEffect()
                        .padding(.trailing, 5)
                        .padding(.bottom, 10)
                        .transition(.scale.combined(with: .opacity))
                        
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
                        .transition(.scale.combined(with: .opacity))
                        .padding(.trailing, 5)
                        .padding(.bottom, 10)
                    }
                    
                    Button {
                        withAnimation {
                            showingActionButtons.toggle()
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 40))
                            .padding(10)
                            .shadow(radius: 5)
                    }
                    .glassEffect()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 20)
                .padding(.bottom, 10)
            }
        }
        .navigationTitle(StringsStore.JournalEntry.navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(StringsStore.JournalEntry.saveTitle) {
                    viewModel.saveJournalEntry()
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settingsManager: viewModel.settingsManager, sourceView: "Journal View")
        }
        .sheet(isPresented: $showingMusicPicker) {
            MusicSelectionView(selectedSong: $viewModel.selectedSong)
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
}

//#Preview {
//    JournalEntry(context: )
//}
