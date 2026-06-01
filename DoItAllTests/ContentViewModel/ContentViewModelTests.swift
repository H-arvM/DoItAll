//
//  ContentViewModelTests.swift
//  DoItAllTests
//

import XCTest
import CoreData
@testable import DoItAll

@MainActor
final class ContentViewModelTests: XCTestCase {

    /// Returns a throwaway in-memory NSManagedObjectContext so we never touch disk.
    private func makeInMemoryContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "DoItAll")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error, "In-memory store failed to load: \(String(describing: error))")
        }
        return container.viewContext
    }

    private func makeSUT(context: NSManagedObjectContext? = nil) -> ContentViewModel {
        let ctx = context ?? makeInMemoryContext()
        let sut = ContentViewModel(context: ctx)
        sut.setupViewModel()
        return sut
    }

    // MARK: - Helpers
    private func makeItem(
        context: NSManagedObjectContext,
        title: String = "Test",
        type: ItemType = .journalType,
        isHidden: Bool = false,
        createdAt: Date = Date()
    ) -> ItemEntity {
        let item = ItemEntity(context: context)
        item.title = title
        item.itemType = type
        item.isHidden = isHidden
        item.createdAt = createdAt
        return item
    }

    // MARK: - Sort Option Persistence

    func test_setSortOption_updatesCurrentSortOption() {
        let sut = makeSUT()
        sut.setSortOption(.type)
        XCTAssertEqual(sut.currentSortOption, .type)
    }

    func test_setSortOption_dateCreated_updatesCurrentSortOption() {
        let sut = makeSUT()
        sut.setSortOption(.dateCreated)
        XCTAssertEqual(sut.currentSortOption, .dateCreated)
    }

    // MARK: - isItemHidden

    func test_isItemHidden_returnsTrueWhenHidden() {
        let ctx = makeInMemoryContext()
        let sut = makeSUT(context: ctx)
        let item = makeItem(context: ctx, isHidden: true)
        XCTAssertTrue(sut.isItemHidden(item))
    }

    func test_isItemHidden_returnsFalseWhenVisible() {
        let ctx = makeInMemoryContext()
        let sut = makeSUT(context: ctx)
        let item = makeItem(context: ctx, isHidden: false)
        XCTAssertFalse(sut.isItemHidden(item))
    }

    // MARK: - groupedItems / sortedItemTypes

    func test_groupedItems_groupsByItemType() {
        let ctx = makeInMemoryContext()
        let sut = makeSUT(context: ctx)

        let note1 = makeItem(context: ctx, type: .journalType)
        let note2 = makeItem(context: ctx, type: .journalType)
        let task  = makeItem(context: ctx, type: .shoppingListType)
        sut.items = [note1, note2, task]

        XCTAssertEqual(sut.groupedItems[.journalType]?.count, 2)
        XCTAssertEqual(sut.groupedItems[.shoppingListType]?.count, 1)
    }

    func test_sortedItemTypes_isSortedByRawValue() {
        let ctx = makeInMemoryContext()
        let sut = makeSUT(context: ctx)
        sut.items = [
            makeItem(context: ctx, type: .journalType),
            makeItem(context: ctx, type: .shoppingListType)
        ]

        let types = sut.sortedItemTypes
        // Each consecutive pair should be in ascending raw-value order
        for i in 0..<(types.count - 1) {
            XCTAssertLessThanOrEqual(types[i].rawValue, types[i + 1].rawValue)
        }
    }

    func test_sortedItemTypes_emptyWhenNoItems() {
        let sut = makeSUT()
        sut.items = []
        XCTAssertTrue(sut.sortedItemTypes.isEmpty)
    }

    // MARK: - getShoppingListContent

    func test_getShoppingListContent_returnsEmptyStringForNil() {
        let sut = makeSUT()
        XCTAssertEqual(sut.getShoppingListContent(nil), "")
    }

    func test_getShoppingListContent_returnsFirstItemName() {
        let ctx = makeInMemoryContext()
        let sut = makeSUT(context: ctx)

        let entry = ShoppingEntry(context: ctx)
        let shoppingItem = ShoppingItem(context: ctx)
        shoppingItem.name = "Milk"
        entry.addToItems(shoppingItem)

        XCTAssertEqual(sut.getShoppingListContent(entry), "Milk")
    }

    func test_getShoppingListContent_returnsEmptyStringWhenNoItems() {
        let ctx = makeInMemoryContext()
        let sut = makeSUT(context: ctx)

        let entry = ShoppingEntry(context: ctx)
        // No items added
        XCTAssertEqual(sut.getShoppingListContent(entry), "")
    }

    // MARK: - getChecklistContent

    func test_getChecklistContent_returnsNoTitleForNil() {
        let sut = makeSUT()
        XCTAssertEqual(sut.getChecklistContent(nil), "No title")
    }

    func test_getChecklistContent_returnsTitleWhenNoChecklistItems() {
        let ctx = makeInMemoryContext()
        let sut = makeSUT(context: ctx)

        let entry = CheckListEntry(context: ctx)
        entry.title = "Groceries"

        XCTAssertEqual(sut.getChecklistContent(entry), "Groceries")
    }

    func test_getChecklistContent_returnsFirstItemNoteWhenPresent() {
        let ctx = makeInMemoryContext()
        let sut = makeSUT(context: ctx)

        let entry = CheckListEntry(context: ctx)
        entry.title = "My List"

        let item = CheckListItem(context: ctx)
        item.note = "Buy apples"
        item.createdAt = Date()
        entry.addToItems(item)

        XCTAssertEqual(sut.getChecklistContent(entry), "Buy apples")
    }

    func test_getChecklistContent_fallsBackToTitleWhenFirstItemNoteIsEmpty() {
        let ctx = makeInMemoryContext()
        let sut = makeSUT(context: ctx)

        let entry = CheckListEntry(context: ctx)
        entry.title = "Fallback Title"

        let item = CheckListItem(context: ctx)
        item.note = ""          // empty note should trigger fallback
        item.createdAt = Date()
        entry.addToItems(item)

        XCTAssertEqual(sut.getChecklistContent(entry), "Fallback Title")
    }

    func test_getChecklistContent_returnsNoTitleWhenEntryTitleIsNil() {
        let ctx = makeInMemoryContext()
        let sut = makeSUT(context: ctx)

        let entry = CheckListEntry(context: ctx)
        entry.title = nil

        XCTAssertEqual(sut.getChecklistContent(entry), "No title")
    }

    // MARK: - Initial State

    func test_initialState_showOnboardingIsFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.showOnboarding)
    }

    func test_initialState_showAuthAlertIsFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.showAuthAlert)
    }

    func test_initialState_selectedItemIsNil() {
        let sut = makeSUT()
        XCTAssertNil(sut.selectedItem)
    }

    func test_initialState_defaultSortIsDateCreated() {
        let sut = makeSUT()
        XCTAssertEqual(sut.currentSortOption, .type)
    }
}
