//
//  JournalEntryViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import Foundation
import CoreData
import UIKit
import PhotosUI
import _PhotosUI_SwiftUI
import MusicKit
import SwiftUI

@MainActor
class JournalEntryViewModel: ObservableObject {
    private var viewContext: NSManagedObjectContext
    public var settingsManager: SettingsManager
    private var item: Item?
    
    @Published var journalText: String = ""
    @Published var journalHeader: String = ""
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var loadedImages: [UIImage] = []
    @Published var loadedImage: UIImage?
    @Published var selectedSong: Song?
    @Published var isShowingEmptyWarning: Bool = false
    
    init(context: NSManagedObjectContext, item: Item? = nil, settingsManager: SettingsManager) {
        self.viewContext = context
        self.settingsManager = settingsManager
        self.item = item
        if let item = item {
            self.journalText = item.journalText ?? ""
            self.journalHeader = item.journalHeader ?? ""
            if let imageDataArray = item.imageData {
                self.loadedImages = imageDataArray.compactMap { UIImage(data: $0) }
            }
        }
    }
    
    func saveJournalEntry() {
        let isTextEmpty = journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isHeaderEmpty = journalHeader.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasNoImages = loadedImages.isEmpty
        let hasNoSong = selectedSong == nil
        
        guard !isTextEmpty || !hasNoImages || !hasNoSong || !isHeaderEmpty else {
            isShowingEmptyWarning = true
            return
        }
        
        let entryToSave = item ?? Item(context: viewContext)
        entryToSave.timestamp = Date()
        entryToSave.journalText = journalText
        entryToSave.journalHeader = journalHeader
        entryToSave.isHidden = settingsManager.isNewEntryHidden
        
        entryToSave.imageData = loadedImages.compactMap { $0.pngData() } as? NSObject as? [Data]
        
        entryToSave.songID = selectedSong?.id.rawValue
        entryToSave.songTitle = selectedSong?.title
        entryToSave.artistName = selectedSong?.artistName
        entryToSave.albumArtURL = selectedSong?.artwork?.url(width: 200, height: 200)?.absoluteString
        
        do {
            try viewContext.save()
            isShowingEmptyWarning = false
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
