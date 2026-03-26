//
//  DisplayViewViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 16/02/2026.
//

import SwiftUI
import CoreData

class DisplayEntryViewModel: ObservableObject {
    @Published var journalText: String
    @Published var header: String
    @Published var journalImages: [UIImage]
    @Published var imageContainerHeight: CGFloat
    
    private static let kCompactHeight: CGFloat = 170
    private static let kMaxImageHeight: CGFloat = 550
    private var kCollapsedHeight: CGFloat { Self.kCompactHeight }
    
    init(item: Item) {
        self.journalText = item.journalText ?? ""
        self.header = item.journalHeader ?? ""
        
        if let imageDataArray = item.imageData as? [Data] {
            self.journalImages = imageDataArray.compactMap { UIImage(data: $0) }
        } else {
            self.journalImages = []
        }
        
        self.imageContainerHeight = Self.kCompactHeight
    }
    
    var imageScale: CGFloat {
        let effectiveHeight = max(0, imageContainerHeight - Self.kCompactHeight)
        let normalizedHeight = effectiveHeight / (Self.kMaxImageHeight - Self.kCompactHeight)
        
        let minSize: CGFloat = 140
        return minSize + normalizedHeight * (Self.kMaxImageHeight - minSize)
    }
    
    var shouldShowFullscreenGallery: Bool {
        imageContainerHeight > Self.kMaxImageHeight * 0.85
    }
    
    var isImageContainerVisible: Bool {
        true
    }
    
    func updateImageContainerHeight(translation: CGFloat) {
        let newHeight = imageContainerHeight - translation
        imageContainerHeight = min(Self.kMaxImageHeight, max(kCollapsedHeight, newHeight))
    }
    
    func snapImageContainer() {
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
