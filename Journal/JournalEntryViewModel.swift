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

class JournalEntryViewModel: ObservableObject {
    private var viewContext: NSManagedObjectContext
    public var settingsManager: SettingsManager
    private var item: Item?

    @Published var journalText: String = ""
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var loadedImages: [UIImage] = []
    @Published var loadedImage: UIImage?
    @Published var selectedSong: Song?
    

    init(context: NSManagedObjectContext, item: Item? = nil, settingsManager: SettingsManager) {
        self.viewContext = context
        self.settingsManager = settingsManager
        self.item = item
        if let item = item {
            self.journalText = item.journalText ?? ""
            if let imageDataArray = item.imageData {
                self.loadedImages = imageDataArray.compactMap { UIImage(data: $0) }
            }
        }
    }

    func saveJournalEntry() {
          guard !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
              return
          }
        
        let entryToSave = item ?? Item(context: viewContext)
        entryToSave.timestamp = Date()
        entryToSave.journalText = journalText
        entryToSave.isHidden = settingsManager.isNewEntryHidden
        
        entryToSave.imageData = loadedImages.compactMap { $0.pngData() } as? NSObject as! [Data]

          do {
              try viewContext.save()
              print("Journal entry saved successfully.")
          } catch {
              let nsError = error as NSError
              fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
          }
      }
}
