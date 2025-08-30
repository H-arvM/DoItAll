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

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    func saveJournalEntry() {
        guard !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        let newEntry = Item(context: viewContext)
        newEntry.timestamp = Date()
        newEntry.journalText = journalText

        do {
            try viewContext.save()
            print("Journal entry saved successfully.")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
