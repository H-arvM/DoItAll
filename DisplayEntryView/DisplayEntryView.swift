//
//  DisplayEntryView.swift
//  DoItAll
//
//  Created by Marc Harvey on 16/02/2026.
//

import SwiftUI

struct DisplayEntryView: View {
    @StateObject private var viewModel: DisplayEntryViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    var onEdit: (() -> Void)? = nil
    
    init(item: Item, onEdit: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: DisplayEntryViewModel(item: item))
        self.onEdit = onEdit
    }
    
    var body: some View {
        VStack(spacing: 0) {
            journalTextSection
            
            if !viewModel.journalImages.isEmpty {
                imageGallerySection
            }
        }
        .navigationTitle($viewModel.header)
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Journal Text Section
    private var journalTextSection: some View {
        ScrollView {
            Text(viewModel.journalText)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
    
    // MARK: - Image Gallery Section
    private var imageGallerySection: some View {
        VStack(spacing: 0) {
            dragHandle
            
            imageContentView
                .opacity(viewModel.isImageContainerVisible ? 1 : 0)
        }
        .frame(height: viewModel.imageContainerHeight)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
        .gesture(dragGesture)
    }
    
    private var dragHandle: some View {
        Capsule()
            .fill(Color.gray.opacity(0.4))
            .frame(width: 40, height: 5)
            .padding(.vertical, 12)
    }
    
    // MARK: - Image Content
    @ViewBuilder
    private var imageContentView: some View {
        if viewModel.shouldShowFullscreenGallery {
            fullscreenGalleryView
        } else {
            horizontalScrollGalleryView
        }
    }
    
    private var fullscreenGalleryView: some View {
        TabView {
            ForEach(Array(viewModel.journalImages.enumerated()), id: \.offset) { index, image in
                ZStack {
                    Color(.systemGray6)
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
    
    private var horizontalScrollGalleryView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(viewModel.journalImages.enumerated()), id: \.offset) { _, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: viewModel.imageScale, height: viewModel.imageScale)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .scrollClipDisabled()
    }
    
    // MARK: - Drag Gesture
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                viewModel.updateImageContainerHeight(translation: value.translation.height)
            }
            .onEnded { _ in
                viewModel.snapImageContainer()
            }
    }
}

//#Preview {
//    DisplayEntryView(item: Item(entity: .init(), insertInto: .none)
//}
