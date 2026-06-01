//
//  FreeFormViewModelTests.swift
//  DoItAllTests
//

import XCTest
import CoreData
@testable import DoItAll

@MainActor
final class FreeFormViewModelTests: XCTestCase {

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

    private func makeEntry(
        context: NSManagedObjectContext,
        title: String = "Test",
        content: String = "",
        wordCount: String = "0",
        entryType: EntryType = .freeForm
    ) -> FreeWritingEntry {
        let entry = FreeWritingEntry(context: context)
        entry.id = UUID()
        entry.title = title
        entry.content = content
        entry.wordCount = wordCount
        entry.createdDate = Date()
        entry.entryType = entryType.rawValue
        return entry
    }

    // MARK: - Initialisation

    func test_init_withNoEntry_hasEmptyDefaults() {
        let sut = FreeFormViewModel()
        XCTAssertEqual(sut.title, "")
        XCTAssertEqual(sut.content, "")
        XCTAssertEqual(sut.entryType, .freeForm)
    }

    func test_init_withNoEntry_respectsInitialEntryType() {
        let sut = FreeFormViewModel(initialEntryType: .journal)
        XCTAssertEqual(sut.entryType, .journal)
    }

    func test_init_withEntry_loadsTitle() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx, title: "My Essay")
        let sut = FreeFormViewModel(entry: entry)
        XCTAssertEqual(sut.title, "My Essay")
    }

    func test_init_withEntry_loadsContent() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx, content: "Once upon a time...")
        let sut = FreeFormViewModel(entry: entry)
        XCTAssertEqual(sut.content, "Once upon a time...")
    }

    func test_init_withEntry_loadsWordCount() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx, wordCount: "42")
        let sut = FreeFormViewModel(entry: entry)
        XCTAssertEqual(sut.wordCount, "42")
    }

    func test_init_withEntry_loadsCreatedDate() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let fixedDate = Date(timeIntervalSince1970: 1_000_000)
        entry.createdDate = fixedDate
        let sut = FreeFormViewModel(entry: entry)
        XCTAssertEqual(sut.createdDate, fixedDate)
    }

    func test_init_withEntry_loadsEntryType() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx, entryType: .journal)
        let sut = FreeFormViewModel(entry: entry)
        XCTAssertEqual(sut.entryType, .journal)
    }

    func test_init_withEntry_nilTitleFallsBackToEmptyString() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        entry.title = nil
        let sut = FreeFormViewModel(entry: entry)
        XCTAssertEqual(sut.title, "")
    }

    func test_init_withEntry_unknownEntryTypeFallsBackToFreeForm() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        entry.entryType = "unknownType"
        let sut = FreeFormViewModel(entry: entry)
        XCTAssertEqual(sut.entryType, .freeForm)
    }

    // MARK: - Word Count Pipeline

    // The Combine pipeline has a 300ms debounce, so we use an expectation
    // with a slightly longer timeout to let it fire.

    func test_wordCount_updatesAfterDebounce() {
        let sut = FreeFormViewModel()
        let expectation = expectation(description: "wordCount updates")

        sut.content = "Hello world this is four"

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(sut.wordCount, "5")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func test_wordCount_countsZeroForEmptyContent() {
        let sut = FreeFormViewModel()
        let expectation = expectation(description: "wordCount zero")

        sut.content = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(sut.wordCount, "0")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 4.0)
    }

    func test_wordCount_ignoresLeadingAndTrailingWhitespace() {
        let sut = FreeFormViewModel()
        let expectation = expectation(description: "wordCount trims")

        sut.content = "   spaced out   "

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(sut.wordCount, "2")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func test_wordCount_handlesMultipleSpacesBetweenWords() {
        let sut = FreeFormViewModel()
        let expectation = expectation(description: "wordCount multi-space")

        sut.content = "one   two   three"

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(sut.wordCount, "3")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func test_wordCount_handlesNewlines() {
        let sut = FreeFormViewModel()
        let expectation = expectation(description: "wordCount newlines")

        sut.content = "line one\nline two\nline three"

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(sut.wordCount, "6")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func test_wordCount_doesNotUpdateBeforeDebounce() {
        let sut = FreeFormViewModel()
        // wordCount starts as "" from init (pipeline hasn't fired yet)
        let initialWordCount = sut.wordCount
        sut.content = "typing something"
        // Check immediately — debounce hasn't elapsed
        XCTAssertEqual(sut.wordCount, initialWordCount)
    }

    // MARK: - saveFreeform — title fallback

    func test_saveFreeform_usesUntitledEntryWhenTitleIsEmpty() {
        let ctx = makeInMemoryContext()
        let sut = FreeFormViewModel()
        sut.title = ""
        sut.saveFreeform(context: ctx)

        let request = NSFetchRequest<FreeWritingEntry>(entityName: "FreeWritingEntry")
        let results = try? ctx.fetch(request)
        XCTAssertEqual(results?.first?.title, "Untitled Entry")
    }

    func test_saveFreeform_preservesNonEmptyTitle() {
        let ctx = makeInMemoryContext()
        let sut = FreeFormViewModel()
        sut.title = "My Manifesto"
        sut.saveFreeform(context: ctx)

        let request = NSFetchRequest<FreeWritingEntry>(entityName: "FreeWritingEntry")
        let results = try? ctx.fetch(request)
        XCTAssertEqual(results?.first?.title, "My Manifesto")
    }

    func test_saveFreeform_persistsContent() {
        let ctx = makeInMemoryContext()
        let sut = FreeFormViewModel()
        sut.title = "Draft"
        sut.content = "It was a dark and stormy night."
        sut.saveFreeform(context: ctx)

        let request = NSFetchRequest<FreeWritingEntry>(entityName: "FreeWritingEntry")
        let results = try? ctx.fetch(request)
        XCTAssertEqual(results?.first?.content, "It was a dark and stormy night.")
    }

    func test_saveFreeform_callsOnSuccessCallback() {
        let ctx = makeInMemoryContext()
        let sut = FreeFormViewModel()
        var fired = false
        sut.saveFreeform(context: ctx) { fired = true }
        XCTAssertTrue(fired)
    }

    func test_saveFreeform_returnsSameEntryOnSubsequentSaves() {
        let ctx = makeInMemoryContext()
        let sut = FreeFormViewModel()
        sut.title = "Stable"
        sut.saveFreeform(context: ctx)

        let request = NSFetchRequest<FreeWritingEntry>(entityName: "FreeWritingEntry")
        let countAfterFirst = (try? ctx.fetch(request))?.count ?? 0

        sut.saveFreeform(context: ctx)
        let countAfterSecond = (try? ctx.fetch(request))?.count ?? 0

        XCTAssertEqual(countAfterFirst, countAfterSecond)
    }

    // MARK: - postSaveNotification

    func test_saveFreeform_postsNotification() {
        let ctx = makeInMemoryContext()
        let sut = FreeFormViewModel()
        let expectation = XCTNSNotificationExpectation(
            name: NSNotification.Name("FreeFormEntrySaved")
        )
        sut.saveFreeform(context: ctx)
        wait(for: [expectation], timeout: 2.0)
    }
}
