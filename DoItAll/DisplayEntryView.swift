//
//  ViewNoteView.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/09/2025.
//

import SwiftUI
import CoreData

// TODO: Make this more generic so every saved item can be displayed here
// May have to make certain parts of view conditional depending
struct DisplayEntryView: View {
    var item: Item
    let gridLayout = [GridItem(.adaptive(minimum: 100))]
    private let kCollapsedHeight: CGFloat = 30
    private static let kCompactHeight: CGFloat = 170
    private static let kMaxImageHeight: CGFloat = 550 // TODO: Make geo based later
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var journalText: String
    @State private var header: String
    @State private var journalImages: [UIImage]
    @State private var imageContainerHeight: CGFloat = Self.kCompactHeight
    
    init(item: Item) {
        self.item = item
        _journalText = State(initialValue: item.journalText ?? "")
        _header = State(initialValue: item.journalHeader ?? "")
        
        if let imageDataArray = item.imageData as? [Data] {
            _journalImages = State(initialValue: imageDataArray.compactMap { UIImage(data: $0) })
        } else {
            _journalImages = State(initialValue: [])
        }
    }
    
    var body: some View {
        VStack {
            // View text
            TextEditor(text: $journalText)
                .frame(maxHeight: .infinity)
                .padding()
                .disabled(true)
            
            // Image grid section
            if !journalImages.isEmpty {
                VStack(spacing: 0) {
                    Capsule()
                        .frame(width: 40, height: 5)
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(.vertical, 8)
                    
                    imageContentView
                        .glassEffect()
                        .opacity(imageContainerHeight > kCollapsedHeight + 10 ? 1 : 0)
                    
                }
                .frame(height: imageContainerHeight)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.horizontal)
                .gesture(dragGesture)
            }
        }
        .navigationTitle($header)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var imageScale: CGFloat {
        let effectiveHeight = max(0, imageContainerHeight - Self.kCompactHeight)
        let normalizedHeight = effectiveHeight / (Self.kMaxImageHeight - Self.kCompactHeight)
        
        let minSize: CGFloat = 140
        return minSize + normalizedHeight * (Self.kMaxImageHeight - minSize)
    }
    
    @ViewBuilder
    var imageContentView: some View {
        if imageContainerHeight > Self.kMaxImageHeight * 0.85 {
            TabView {
                ForEach(journalImages, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .tag(image)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(maxHeight: .infinity)
            .padding(.bottom, 10)
        } else {
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    ForEach(journalImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageScale, height: imageScale)
                            .clipped()
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
    }
    
    // MARK: - Drag Gesture
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                let newHeight = imageContainerHeight - value.translation.height
                
                imageContainerHeight = min(Self.kMaxImageHeight, max(kCollapsedHeight, newHeight))
            }
            .onEnded { value in
                let threshold = (Self.kMaxImageHeight - kCollapsedHeight) * 0.4
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if imageContainerHeight > kCollapsedHeight + threshold {
                        imageContainerHeight = Self.kMaxImageHeight
                    } else {
                        imageContainerHeight = kCollapsedHeight
                    }
                }
            }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
