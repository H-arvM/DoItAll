//
//  JournalViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 08/04/2026.
//

import SwiftUI
import PhotosUI
import CoreData
import Combine

@MainActor
final class JournalViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var createdDate: Date = Date()
    @Published var entryType: EntryType = .journal

    @Published var selectedPhotos: [UIImage] = []
    @Published var photoSelection: [PhotosPickerItem] = []
    @Published var selectedTrack: MusicTrack?
    
    @Published var showMusicPicker: Bool = false
    @Published var isPhotosExpanded: Bool = false
    @Published var isMusicExpanded: Bool = false

    private var existingEntry: JournalEntry?
    
    var formattedDate: String {
        createdDate.funFormatString
    }
    
    init(entry: JournalEntry? = nil, initialEntryType: EntryType = .journal) {
        self.existingEntry = entry
        
        if let entry = entry {
            loadExistingEntry(entry)
        } else {
            self.entryType = initialEntryType
        }
    }
    
    private func loadExistingEntry(_ entry: JournalEntry) {
        title = entry.title ?? ""
        content = entry.content ?? ""
        createdDate = entry.createdDate ?? Date()
        entryType = EntryType(rawValue: entry.entryType!) ?? .journal
        
        loadMusicFromEntry(entry)
        loadPhotosFromEntry(entry)
    }
    
    private func loadMusicFromEntry(_ entry: JournalEntry) {
        guard let trackID = entry.musicTrackID,
              let trackTitle = entry.musicTrackTitle,
              let trackArtist = entry.musicArtist else { return }
        
        let artworkURL = entry.musicArtworkURL.flatMap { URL(string: $0) }
        selectedTrack = MusicTrack(
            id: trackID,
            title: trackTitle,
            artist: trackArtist,
            artworkURL: artworkURL)
    }
    
    private func loadPhotosFromEntry(_ entry: JournalEntry) {
        guard let photoData = entry.photoData,
              let image = UIImage(data: photoData) else { return }
        
        selectedPhotos = [image]
    }
    
    private func getOrCreateEntry(in context: NSManagedObjectContext) -> JournalEntry {
        if let existing = existingEntry {
            return existing
        }
        
        let entry = JournalEntry(context: context)
        entry.id = UUID()
        entry.createdDate = createdDate
        entry.entryType = entryType.rawValue
        
        createAssociatedItem(for: entry, in: context)
        
        return entry
    }
    
    private func createAssociatedItem(for entry: JournalEntry, in context: NSManagedObjectContext) {
        let item = ItemEntity(context: context)
        item.id = UUID()
        item.title = title.isEmpty ? "Untitled Entry" : title
        item.type = itemTypeForEntryType(entryType)
        item.isHidden = false
        item.createdAt = Date()
        item.journalEntry = entry
        entry.item = item
    }
    
    private func itemTypeForEntryType(_ entryType: EntryType) -> String {
        switch entryType {
        case .journal:
            return ItemType.journalType.rawValue
        case .shoppingList:
            return ItemType.shoppingListType.rawValue
        case .freeForm:
            return ItemType.freeFormType.rawValue
        case .lifeAdmin:
            return ItemType.lifeAdminType.rawValue
        case .list:
            return ItemType.generalListType.rawValue
        }
    }

    private func updateEntryProperties(_ entry: JournalEntry) {
        entry.title = title.isEmpty ? "Untitled Entry" : title
        entry.content = content
        entry.entryType = entryType.rawValue
    }
    
    private func updateMediaProperties(_ entry: JournalEntry) {
        if entryType == .journal {
            updateMusicProperties(entry)
            updatePhotoProperties(entry)
        } else {
            clearMediaProperties(entry)
        }
    }
    
    private func updateMusicProperties(_ entry: JournalEntry) {
        if let track = selectedTrack {
            entry.musicTrackID = track.id
            entry.musicTrackTitle = track.title
            entry.musicArtist = track.artist
            entry.musicArtworkURL = track.artworkURL?.absoluteString
        } else {
            clearMusicProperties(entry)
        }
    }
    
    private func updatePhotoProperties(_ entry: JournalEntry) {
        if !selectedPhotos.isEmpty,
           let firstPhoto = selectedPhotos.first,
           let photoData = firstPhoto.jpegData(compressionQuality: 0.8) {
            entry.photoData = photoData
        } else {
            entry.photoData = nil
        }
    }
    
    private func clearMediaProperties(_ entry: JournalEntry) {
        clearMusicProperties(entry)
        entry.photoData = nil
    }
    
    func saveJournal(context: NSManagedObjectContext, onSuccess: (() -> Void)? = nil) {
        let entry = getOrCreateEntry(in: context)
        updateEntryProperties(entry)
        updateMediaProperties(entry)
        
        do {
            try context.save()
            existingEntry = entry
            postSaveNotification()
            onSuccess?()
        } catch {
            // TODO: Handle this in a nicer way
            print("Error saving jounrnal")
        }
    }
    
    private func clearMusicProperties(_ entry: JournalEntry) {
        entry.musicTrackID = nil
        entry.musicTrackTitle = nil
        entry.musicArtist = nil
        entry.musicArtworkURL = nil
    }
    
    private func postSaveNotification() {
        NotificationCenter.default.post(
            name: NSNotification.Name("JournalEntrySaved"),
            object: nil
        )
     }
    
    func removePhoto(_ photo: UIImage) {
        selectedPhotos.removeAll { $0 == photo }
    }
    
    func loadPhoto(from items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }
        
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        selectedPhotos.append(image)
                    }
                }
            }
            await MainActor.run {
                photoSelection = []
            }
        }
    }
}

