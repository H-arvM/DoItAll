//
//  JournalEntryViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import Foundation
import CoreData

class JournalEntryViewModel: ObservableObject {
    @Published var journalText: String = ""
    private var viewContext: NSManagedObjectContext
    public var settingsManager: SettingsManager

    init(context: NSManagedObjectContext, settingsManager: SettingsManager) {
        self.viewContext = context
        self.settingsManager = settingsManager
    }

    func saveJournalEntry() {
        guard !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        let newEntry = Item(context: viewContext)
        newEntry.timestamp = Date()
        newEntry.journalText = journalText
        newEntry.isHidden = settingsManager.isNewEntryHidden

        do {
            try viewContext.save()
            print("Journal entry saved successfully.")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
