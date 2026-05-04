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
    @State private var drawerOffset: CGFloat = 0
    @State private var isExpanded: Bool = false
    @State private var showMusicPicker = false
    @State private var showReplaceTrackAlert = false
    @State private var showMusicAuthAlert = false
    
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var viewModel: JournalViewModel
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colourScheme
    
    let mode: EditOrViewMode
    var onSave: (() -> Void)?
    
    let parentItem: ItemEntity?
    
    init(item: ItemEntity? = nil, mode: EditOrViewMode = .edit, entry: JournalEntry? = nil, initialEntryType: EntryType = .journal, onSave: (() -> Void)? = nil) {
        self.parentItem = item // Store the item reference
        self.mode = mode
        self.onSave = onSave
        
        _viewModel = StateObject(wrappedValue: JournalViewModel(entry: entry, initialEntryType: initialEntryType))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ThemeBackgroundView(theme: themeManager.selectedTheme)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    draggablePhotosDrawer
                        .padding(.top, 10)
                        .padding(.horizontal, 10)
                    
                    headerSection
                        .padding(.vertical, 5)
                    
                    PulsingDividerBar()
                        .padding(.vertical, 4)
                    
                    contentSection
                    
                    Spacer(minLength: 10)
                }
            }
        }
        .navigationBarBackButtonHidden(mode == .edit)
        .onChange(of: viewModel.photoSelection) { oldValue, newValue in
            viewModel.loadPhoto(from: newValue)
        }
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar { toolbarItems }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        GenericSingularHeaderSection(
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
        ToolbarItem(placement: .topBarLeading) {
            if mode == .edit {
                CancelButton()
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            if mode == .edit {
                photoPickerButton
                SaveButton(
                    viewModel: viewModel,
                    context: viewContext,
                    onSave: onSave ?? { dismiss() }
                )
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
        private var draggablePhotosDrawer: some View {
            if !viewModel.selectedPhotos.isEmpty {
                VStack(spacing: 8) {
                    photosSection
                        .frame(height: isExpanded ? 250 : 100)
                        .padding(.horizontal, 10)
                    
                    // Grabber handle now uses the theme color with transparency
                    Capsule()
                        .frame(width: 36, height: 5)
                        .foregroundStyle(themeManager.selectedTheme.primaryColour.opacity(0.4))
                        .padding(.bottom, 8)
                }
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(.thinMaterial)
                        
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(themeManager.selectedTheme.primaryColour.opacity(0.12))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    themeManager.selectedTheme.secondaryColour.opacity(0.5),
                                    themeManager.selectedTheme.secondaryColour.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: themeManager.selectedTheme.primaryColour.opacity(0.1), radius: 15, y: 10)
                .offset(y: drawerOffset)
                .padding(.horizontal, 12)
                .transition(.move(edge: .top).combined(with: .opacity))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            drawerOffset = value.translation.height > 0 ? value.translation.height * 0.3 : value.translation.height
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                if value.translation.height > 50 { isExpanded = true }
                                else if value.translation.height < -50 { isExpanded = false }
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
