//
//  JournalView.swift
//  DoItAll
//
//  Created by Marc Harvey on 08/04/2026.
//

import SwiftUI
import PhotosUI

enum EditOrViewMode {
    case edit
    case view
}

struct JournalView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var viewModel: JournalViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var drawerOffset: CGFloat = 0
    @State private var isExpanded: Bool = false
    
    let mode: EditOrViewMode
    var onSave: (() -> Void)?
    
    init(mode: EditOrViewMode = .edit, entry: JournalEntry? = nil, initialEntryType: EntryType = .journal, onSave: (() -> Void)? = nil) {
        self.mode = mode
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: JournalViewModel(entry: entry, initialEntryType: initialEntryType))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ThemeBackgroundView(theme: themeManager.selectedTheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    contentSection
                    musicSection
                    
                    Spacer(minLength: 150)
                }
                .padding()
            }
            draggablePhotosDrawer
        }
        .onChange(of: viewModel.photoSelection) { oldValue, newValue in
            viewModel.loadPhoto(from: newValue)
        }
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private var headerSection: some View {
        JournalHeaderSection(
            mode: mode,
            viewModel: viewModel,
            themeManager: themeManager
        )
    }
    
    @ViewBuilder
    private var contentSection: some View {
        JournalContentSection(
            mode: mode,
            viewModel: viewModel,
            themeManager: themeManager
        )
    }
    
    @ViewBuilder
    private var musicSection: some View {
        if viewModel.entryType == .journal, let track = viewModel.selectedTrack {
            JournalMusicSelection(
                mode: mode,
                track: track,
                viewModel: viewModel,
                themeManager: themeManager
            )
        }
    }
    
    @ViewBuilder
    private var photosSection: some View {
        if viewModel.entryType == .journal, !viewModel.selectedPhotos.isEmpty {
            JournalPhotosSelection(
                mode: mode,
                viewModel: viewModel,
                themeManager: themeManager,
                isParentExpanded: isExpanded
            )
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        if mode == .edit {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if viewModel.entryType == .journal {
                    photoPickerButton
                    musicPickerButton
                }
                saveButton
            }
        }
    }
    
    // MARK: - Toolbar Buttons
    
    @ViewBuilder
    private var photoPickerButton: some View {
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
    
    @ViewBuilder
    private var musicPickerButton: some View {
        Button {
            viewModel.showMusicPicker = true
        } label: {
            Image(systemName: "music.note")
                .foregroundStyle(themeManager.selectedTheme.primaryColour)
        }
    }
    
    @ViewBuilder
    private var saveButton: some View {
        Button {
            viewModel.saveJournal(context: viewContext) {
                if let onSave = onSave {
                    onSave()
                } else {
                    dismiss()
                }
            }
        } label: {
            Image(systemName: "square.and.arrow.down")
                .foregroundStyle(themeManager.selectedTheme.primaryColour)
        }
    }
    
    @ViewBuilder
    private var draggablePhotosDrawer: some View {
        if !viewModel.selectedPhotos.isEmpty {
            VStack(spacing: 0) {
                Capsule()
                    .frame(width: 40, height: 6)
                    .foregroundStyle(.secondary.opacity(0.5))
                    .padding(.vertical, 12)
                
                JournalPhotosSelection(
                    mode: mode,
                    viewModel: viewModel,
                    themeManager: themeManager,
                    isParentExpanded: isExpanded
                )
                .frame(height: isExpanded ? 400 : 110)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
            )
            // Transition makes it slide in when the first photo is added
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .offset(y: drawerOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height < 0 {
                            drawerOffset = value.translation.height * 0.3
                        } else {
                            drawerOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if value.translation.height < -60 {
                                isExpanded = true
                            } else if value.translation.height > 60 {
                                isExpanded = false
                            }
                            drawerOffset = 0
                        }
                    }
            )
        }
    }
}

#Preview {
    JournalView()
}
