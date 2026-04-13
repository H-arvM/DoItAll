//
//  JournalView.swift
//  DoItAll
//
//  Created by Marc Harvey on 08/04/2026.
//

import SwiftUI
import PhotosUI

enum JournalMode {
    case edit
    case view
}

struct JournalView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var viewModel: JournalViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let mode: JournalMode
    
    init(mode: JournalMode = .edit, entry: JournalEntry? = nil, initialEntryType: EntryType = .journal) {
        self.mode = mode
        _viewModel = StateObject(wrappedValue: JournalViewModel(entry: entry, initialEntryType: initialEntryType))
    }
    
    var body: some View {
        ZStack{
            ThemeBackgroundView(theme: themeManager.selectedTheme)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    JournalHeaderSection(
                        mode: mode,
                        viewModel: viewModel,
                        themeManager: themeManager
                        
                    )
                    
                    JournalContentSection(
                        mode: mode,
                        viewModel: viewModel,
                        themeManager: themeManager
                        
                    )
                    
                    if viewModel.entryType == .journal, let track = viewModel.selectedTrack {
                        JournalMusicSelection(
                            mode: mode,
                            track: track,
                            viewModel: viewModel,
                            themeManager: themeManager
                        )
                    }
                    
                    if viewModel.entryType == .journal, !viewModel.selectedPhotos.isEmpty {
                        JournalPhotosSelection(
                            mode: mode,
                            viewModel: viewModel,
                            themeManager: themeManager)
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if mode == .edit {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if viewModel.entryType == .journal {
                        PhotosPicker(
                            selection: $viewModel.photoSelection,
                            maxSelectionCount: 10,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundStyle(themeManager.selectedTheme.primaryColour)
                        }
                    }
                    
                    if viewModel.entryType == .journal {
                        Button {
                            viewModel.showMusicPicker = true
                        } label: {
                            Image(systemName: "music.note")
                                .foregroundStyle(themeManager.selectedTheme.primaryColour)
                        }
                    }
                    
                    Button {
                        viewModel.saveJournal(context: viewContext) {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundStyle(themeManager.selectedTheme.primaryColour)
                    }
                }
            }
        }
        .onChange(of: viewModel.photoSelection) { _, newValue in
            viewModel.loadPhoto(from: newValue)
        }
        .sheet(isPresented: $viewModel.showMusicPicker) {
            MusicPickerView(selectedTrack: $viewModel.selectedTrack)
        }
    }
}

#Preview {
    JournalView()
}
