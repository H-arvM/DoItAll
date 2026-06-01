//
//  ShoppingListViewModelTests.swift
//  DoItAllTests
//

import XCTest
import CoreData
@testable import DoItAll

@MainActor
final class ShoppingListViewModelTests: XCTestCase {

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

    private func makeEntry(context: NSManagedObjectContext) -> ShoppingEntry {
        let entry = ShoppingEntry(context: context)
        entry.id = UUID()
        entry.createdDate = Date()
        entry.entryType = EntryType.shoppingList.rawValue
        return entry
    }

    private func makeShoppingItem(
        context: NSManagedObjectContext,
        entry: ShoppingEntry,
        name: String,
        quantity: String = "1"
    ) -> ShoppingItem {
        let item = ShoppingItem(context: context)
        item.id = UUID()
        item.name = name
        item.quantity = quantity
        item.isChecked = false
        item.entry = entry
        return item
    }

    // MARK: - Initialisation

    func test_init_withNoEntry_hasEmptyDefaults() {
        let sut = ShoppingListViewModel()
        XCTAssertEqual(sut.itemName, "")
        XCTAssertEqual(sut.quantity, "")
        XCTAssertNil(sut.existingEntry)
        XCTAssertEqual(sut.entryType, .shoppingList)
    }

    func test_init_withNoEntry_respectsInitialEntryType() {
        let sut = ShoppingListViewModel(initialEntryType: .list)
        XCTAssertEqual(sut.entryType, .list)
    }

    func test_init_withEntry_loadsCreatedDate() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let fixedDate = Date(timeIntervalSince1970: 800_000)
        entry.createdDate = fixedDate
        let sut = ShoppingListViewModel(entry: entry)
        XCTAssertEqual(sut.createdDate, fixedDate)
    }

    func test_init_withEntry_loadsEntryType() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        entry.entryType = EntryType.freeForm.rawValue
        let sut = ShoppingListViewModel(entry: entry)
        XCTAssertEqual(sut.entryType, .freeForm)
    }

    func test_init_withEntry_unknownEntryTypeFallsBackToShoppingList() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        entry.entryType = "nonsense"
        let sut = ShoppingListViewModel(entry: entry)
        XCTAssertEqual(sut.entryType, .shoppingList)
    }

    // MARK: - sortedItems

    func test_sortedItems_returnsItemsAlphabeticallyByName() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        makeShoppingItem(context: ctx, entry: entry, name: "Milk")
        makeShoppingItem(context: ctx, entry: entry, name: "Apples")
        makeShoppingItem(context: ctx, entry: entry, name: "Bread")
        let sut = ShoppingListViewModel(entry: entry)
        XCTAssertEqual(sut.sortedItems.map { $0.name }, ["Apples", "Bread", "Milk"])
    }

    func test_sortedItems_emptyWhenEntryHasNoItems() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let sut = ShoppingListViewModel(entry: entry)
        XCTAssertTrue(sut.sortedItems.isEmpty)
    }

    func test_sortedItems_emptyWhenNoExistingEntry() {
        let sut = ShoppingListViewModel()
        XCTAssertTrue(sut.sortedItems.isEmpty)
    }

    func test_sortedItems_nilNameSortsBeforeOtherNames() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        makeShoppingItem(context: ctx, entry: entry, name: "Yoghurt")
        let nilItem = ShoppingItem(context: ctx)
        nilItem.id = UUID()
        nilItem.name = nil
        nilItem.entry = entry
        let sut = ShoppingListViewModel(entry: entry)
        XCTAssertNil(sut.sortedItems.first?.name)
    }

    // MARK: - addItem

    func test_addItem_withEmptyName_doesNotCreateEntry() {
        let ctx = makeInMemoryContext()
        let sut = ShoppingListViewModel()
        sut.itemName = ""
        sut.addItem(context: ctx)
        XCTAssertNil(sut.existingEntry)
    }

    func test_addItem_clearsItemNameAfterSaving() {
        let ctx = makeInMemoryContext()
        let sut = ShoppingListViewModel()
        sut.itemName = "Eggs"
        sut.addItem(context: ctx)
        XCTAssertEqual(sut.itemName, "")
    }

    func test_addItem_clearsQuantityAfterSaving() {
        let ctx = makeInMemoryContext()
        let sut = ShoppingListViewModel()
        sut.itemName = "Eggs"
        sut.quantity = "6"
        sut.addItem(context: ctx)
        XCTAssertEqual(sut.quantity, "")
    }

    func test_addItem_defaultsQuantityToOneWhenEmpty() {
        let ctx = makeInMemoryContext()
        let sut = ShoppingListViewModel()
        sut.itemName = "Butter"
        sut.quantity = ""
        sut.addItem(context: ctx)
        XCTAssertEqual(sut.sortedItems.first?.quantity, "1")
    }

    func test_addItem_preservesExplicitQuantity() {
        let ctx = makeInMemoryContext()
        let sut = ShoppingListViewModel()
        sut.itemName = "Oranges"
        sut.quantity = "4"
        sut.addItem(context: ctx)
        XCTAssertEqual(sut.sortedItems.first?.quantity, "4")
    }

    func test_addItem_setsExistingEntry() {
        let ctx = makeInMemoryContext()
        let sut = ShoppingListViewModel()
        sut.itemName = "Cheese"
        sut.addItem(context: ctx)
        XCTAssertNotNil(sut.existingEntry)
    }

    func test_addItem_incrementsItemCount() {
        let ctx = makeInMemoryContext()
        let sut = ShoppingListViewModel()
        sut.itemName = "Tea"
        sut.addItem(context: ctx)
        sut.itemName = "Coffee"
        sut.addItem(context: ctx)
        XCTAssertEqual(sut.sortedItems.count, 2)
    }

    func test_addItem_newItemIsUncheckedByDefault() {
        let ctx = makeInMemoryContext()
        let sut = ShoppingListViewModel()
        sut.itemName = "Pasta"
        sut.addItem(context: ctx)
        XCTAssertFalse(sut.sortedItems.first?.isChecked ?? true)
    }

    // MARK: - saveShoppingEntry

    func test_saveShoppingEntry_setsExistingEntry() {
        let ctx = makeInMemoryContext()
        let sut = ShoppingListViewModel()
        sut.saveShoppingEntry(context: ctx)
        XCTAssertNotNil(sut.existingEntry)
    }

    func test_saveShoppingEntry_callsOnSuccessCallback() {
        let ctx = makeInMemoryContext()
        let sut = ShoppingListViewModel()
        var fired = false
        sut.saveShoppingEntry(context: ctx) { fired = true }
        XCTAssertTrue(fired)
    }

    func test_saveShoppingEntry_doesNotCreateDuplicateEntries() {
        let ctx = makeInMemoryContext()
        let sut = ShoppingListViewModel()
        sut.saveShoppingEntry(context: ctx)
        sut.saveShoppingEntry(context: ctx)
        let request = NSFetchRequest<ShoppingEntry>(entityName: "ShoppingEntry")
        let count = (try? ctx.fetch(request))?.count ?? 0
        XCTAssertEqual(count, 1)
    }

    func test_saveShoppingEntry_postsNotification() {
        let ctx = makeInMemoryContext()
        let sut = ShoppingListViewModel()
        let expectation = XCTNSNotificationExpectation(
            name: NSNotification.Name("ShoppingEntrySaved")
        )
        sut.saveShoppingEntry(context: ctx)
        wait(for: [expectation], timeout: 1.0)
    }
}
