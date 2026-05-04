//
//  dunno lol.swift
//  DoItAll
//
//  Created by Marc Harvey on 22/04/2026.
//

import Foundation
import CoreData

extension ItemEntity {
    func getOrCreateJournalEntry(context: NSManagedObjectContext) -> JournalEntry {
        if let existing = self.journalEntry {
            return existing
        }
        let newEntry = JournalEntry(context: context)
        newEntry.id = self.id
        newEntry.createdDate = Date()
        newEntry.entryType = self.type
        self.journalEntry = newEntry
        
        return newEntry
    }
    
    func getOrCreateFreeWritingEntry(context: NSManagedObjectContext) -> FreeWritingEntry {
        if let existing = self.freeWritingEntry {
            return existing
        }
        let newEntry = FreeWritingEntry(context: context)
        newEntry.id = self.id
        newEntry.createdDate = Date()
        newEntry.entryType = self.type
        self.freeWritingEntry = newEntry
        return newEntry
    }
    
    func getOrCreateShoppingEntry(context: NSManagedObjectContext) -> ShoppingEntry {
        if let existing = self.shoppingEntry {
            return existing
        }
        let newEntry = ShoppingEntry(context: context)
        newEntry.id = self.id
        newEntry.createdDate = Date()
        newEntry.entryType = self.type
        self.shoppingEntry = newEntry
        return newEntry
    }
    
    func getOrCreateAdminEntry(context: NSManagedObjectContext) -> TaskEntry {
        if let existing = self.taskItemEntry {
            return existing
        }
        let newEntry = TaskEntry(context: context)
        newEntry.id = self.id
        newEntry.createdAt = Date()
        newEntry.entryType = self.type
        self.taskItemEntry = newEntry
        return newEntry
    }
    
    func getOrCreateChecklistEntry(context: NSManagedObjectContext) -> CheckListEntry {
        if let existing = self.checkListEntry {
            return existing
        }
        let newEntry = CheckListEntry(context: context)
        newEntry.id = self.id
        newEntry.createdAt = Date()
        newEntry.entryType = self.type
        self.checkListEntry = newEntry
        return newEntry
    }
}

