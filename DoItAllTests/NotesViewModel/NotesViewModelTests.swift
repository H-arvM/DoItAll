//
//  NotesViewModelTests.swift
//  DoItAllTests
//

import XCTest
import CoreData
@testable import DoItAll

@MainActor
final class NotesViewModelTests: XCTestCase {

    // MARK: - In-Memory Stack

    private func makeInMemoryContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "DoItAll")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        return container.viewContext
    }

    private func makeEntry(context: NSManagedObjectContext, title: String = "Test") -> CheckListEntry {
        let entry = CheckListEntry(context: context)
        entry.id = UUID()
        entry.title = title
        entry.createdAt = Date()
        entry.entryType = EntryType.list.rawValue
        return entry
    }

    // MARK: - Initialisation

    func test_init_withNoEntry_hasEmptyDefaults() {
        let sut = NotesViewModel()
        XCTAssertEqual(sut.title, "")
        XCTAssertEqual(sut.newItemText, "")
        XCTAssertNil(sut.existingEntry)
    }

    func test_init_withEntry_loadsTitle() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx, title: "My Checklist")
        let sut = NotesViewModel(entry: entry)
        XCTAssertEqual(sut.title, "My Checklist")
    }

    func test_init_withEntry_loadsCreatedDate() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let fixedDate = Date(timeIntervalSince1970: 1_000_000)
        entry.createdAt = fixedDate
        let sut = NotesViewModel(entry: entry)
        XCTAssertEqual(sut.createdDate, fixedDate)
    }

    func test_init_withEntry_loadsEntryType() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        entry.entryType = EntryType.journal.rawValue
        let sut = NotesViewModel(entry: entry)
        XCTAssertEqual(sut.entryType, .journal)
    }

    func test_init_withEntry_nilTitleFallsBackToEmptyString() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        entry.title = nil
        let sut = NotesViewModel(entry: entry)
        XCTAssertEqual(sut.title, "")
    }

    func test_init_withEntry_unknownEntryTypeFallsBackToList() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        entry.entryType = "nonExistentType"
        let sut = NotesViewModel(entry: entry)
        XCTAssertEqual(sut.entryType, .list)
    }

    func test_init_withNoEntry_respectsInitialEntryType() {
        let sut = NotesViewModel(initialEntryType: .shoppingList)
        XCTAssertEqual(sut.entryType, .shoppingList)
    }

    // MARK: - sortedItems

    func test_sortedItems_returnsItemsSortedByNoteAlphabetically() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)

        let itemC = CheckListItem(context: ctx); itemC.note = "Carrots"; itemC.items = entry
        let itemA = CheckListItem(context: ctx); itemA.note = "Apples";  itemA.items = entry
        let itemB = CheckListItem(context: ctx); itemB.note = "Bread";   itemB.items = entry

        let sut = NotesViewModel(entry: entry)
        let notes = sut.sortedItems.map { $0.note }
        XCTAssertEqual(notes, ["Apples", "Bread", "Carrots"])
    }

    func test_sortedItems_emptyWhenEntryHasNoItems() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let sut = NotesViewModel(entry: entry)
        XCTAssertTrue(sut.sortedItems.isEmpty)
    }

    func test_sortedItems_emptyWhenNoExistingEntry() {
        let sut = NotesViewModel()
        XCTAssertTrue(sut.sortedItems.isEmpty)
    }

    func test_sortedItems_nilNoteTreatedAsEmptyString() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)

        let itemNil = CheckListItem(context: ctx); itemNil.note = nil;    itemNil.items = entry
        let itemZ   = CheckListItem(context: ctx); itemZ.note   = "Zest"; itemZ.items   = entry

        let sut = NotesViewModel(entry: entry)
        // nil note sorts before "Zest"
        XCTAssertEqual(sut.sortedItems.first?.note, nil)
        XCTAssertEqual(sut.sortedItems.last?.note, "Zest")
    }

    // MARK: - addItem

    func test_addItem_withEmptyText_doesNotCreateItem() {
        let ctx = makeInMemoryContext()
        let sut = NotesViewModel()
        sut.newItemText = ""
        sut.addItem(context: ctx)
        XCTAssertNil(sut.existingEntry)
    }

    func test_addItem_clearsNewItemTextAfterSaving() {
        let ctx = makeInMemoryContext()
        let sut = NotesViewModel()
        sut.newItemText = "Buy milk"
        sut.addItem(context: ctx)
        XCTAssertEqual(sut.newItemText, "")
    }

    func test_addItem_setsExistingEntry() {
        let ctx = makeInMemoryContext()
        let sut = NotesViewModel()
        sut.newItemText = "First item"
        sut.addItem(context: ctx)
        XCTAssertNotNil(sut.existingEntry)
    }

    func test_addItem_usesNewListTitleWhenTitleIsEmpty() {
        let ctx = makeInMemoryContext()
        let sut = NotesViewModel()
        sut.title = ""
        sut.newItemText = "An item"
        sut.addItem(context: ctx)
        XCTAssertEqual(sut.existingEntry?.title, "New List")
    }

    func test_addItem_preservesCustomTitle() {
        let ctx = makeInMemoryContext()
        let sut = NotesViewModel()
        sut.title = "Weekend Errands"
        sut.newItemText = "Pick up parcel"
        sut.addItem(context: ctx)
        XCTAssertEqual(sut.existingEntry?.title, "Weekend Errands")
    }

    func test_addItem_incrementsItemCount() {
        let ctx = makeInMemoryContext()
        let sut = NotesViewModel()
        sut.newItemText = "Item one"
        sut.addItem(context: ctx)
        sut.newItemText = "Item two"
        sut.addItem(context: ctx)
        XCTAssertEqual(sut.sortedItems.count, 2)
    }

    // MARK: - toggleItem

    func test_toggleItem_flipsIsChecked() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let item = CheckListItem(context: ctx)
        item.isChecked = false
        item.items = entry

        let sut = NotesViewModel(entry: entry)
        sut.toggleItem(item, context: ctx)
        XCTAssertTrue(item.isChecked)
    }

    func test_toggleItem_flipsBackToFalse() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let item = CheckListItem(context: ctx)
        item.isChecked = true
        item.items = entry

        let sut = NotesViewModel(entry: entry)
        sut.toggleItem(item, context: ctx)
        XCTAssertFalse(item.isChecked)
    }

    // MARK: - saveNotesEntry title fallback

    func test_saveNotesEntry_usesNewListWhenTitleEmpty() {
        let ctx = makeInMemoryContext()
        let sut = NotesViewModel()
        sut.title = ""
        sut.saveNotesEntry(context: ctx)
        XCTAssertEqual(sut.existingEntry?.title, "New List")
    }

    func test_saveNotesEntry_preservesNonEmptyTitle() {
        let ctx = makeInMemoryContext()
        let sut = NotesViewModel()
        sut.title = "Packed Lunch"
        sut.saveNotesEntry(context: ctx)
        XCTAssertEqual(sut.existingEntry?.title, "Packed Lunch")
    }

    func test_saveNotesEntry_callsOnSuccessCallback() {
        let ctx = makeInMemoryContext()
        let sut = NotesViewModel()
        sut.title = "Any"
        var callbackFired = false
        sut.saveNotesEntry(context: ctx) { callbackFired = true }
        XCTAssertTrue(callbackFired)
    }

    func test_saveNotesEntry_setsExistingEntry() {
        let ctx = makeInMemoryContext()
        let sut = NotesViewModel()
        sut.title = "New one"
        sut.saveNotesEntry(context: ctx)
        XCTAssertNotNil(sut.existingEntry)
    }

    // MARK: - itemTypeForEntryType (via addItem side-effects)
    // The private method is exercised indirectly through the ItemEntity
    // created inside getOrCreateEntry → createAssociatedItem.

    private func itemTypeAfterAdd(entryType: EntryType) -> String? {
        let ctx = makeInMemoryContext()
        let sut = NotesViewModel(initialEntryType: entryType)
        sut.newItemText = "trigger"
        sut.addItem(context: ctx)

        let request = NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
        let results = try? ctx.fetch(request)
        return results?.first?.type
    }

    func test_itemType_journalMapsToJournalType() {
        XCTAssertEqual(itemTypeAfterAdd(entryType: .journal), ItemType.journalType.rawValue)
    }

    func test_itemType_shoppingListMapsToShoppingListType() {
        XCTAssertEqual(itemTypeAfterAdd(entryType: .shoppingList), ItemType.shoppingListType.rawValue)
    }

    func test_itemType_freeFormMapsToFreeFormType() {
        XCTAssertEqual(itemTypeAfterAdd(entryType: .freeForm), ItemType.freeFormType.rawValue)
    }

    func test_itemType_lifeAdminMapsToLifeAdminType() {
        XCTAssertEqual(itemTypeAfterAdd(entryType: .lifeAdmin), ItemType.lifeAdminType.rawValue)
    }

    func test_itemType_listMapsToGeneralNoteType() {
        XCTAssertEqual(itemTypeAfterAdd(entryType: .list), ItemType.generalNoteType.rawValue)
    }
}
