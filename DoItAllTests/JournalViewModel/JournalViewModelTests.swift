//
//  JournalViewModelTests.swift
//  DoItAllTests
//

import XCTest
import CoreData
@testable import DoItAll

@MainActor
final class JournalViewModelTests: XCTestCase {
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
        content: String = "",
        entryType: EntryType = .journal
    ) -> JournalEntry {
        let entry = JournalEntry(context: context)
        entry.id = UUID()
        entry.content = content
        entry.createdDate = Date()
        entry.entryType = entryType.rawValue
        return entry
    }

    private func makeImage(color: UIColor = .red, size: CGSize = CGSize(width: 10, height: 10)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    // MARK: - Initialisation

    func test_init_withNoEntry_hasEmptyDefaults() {
        let sut = JournalViewModel()
        XCTAssertEqual(sut.title, "")
        XCTAssertEqual(sut.content, "")
        XCTAssertEqual(sut.entryType, .journal)
        XCTAssertTrue(sut.selectedPhotos.isEmpty)
        XCTAssertNil(sut.selectedTrack)
    }

    func test_init_withNoEntry_uiStateDefaultsToCollapsed() {
        let sut = JournalViewModel()
        XCTAssertFalse(sut.showMusicPicker)
        XCTAssertFalse(sut.isPhotosExpanded)
        XCTAssertFalse(sut.isMusicExpanded)
    }

    func test_init_withNoEntry_respectsInitialEntryType() {
        let sut = JournalViewModel(initialEntryType: .freeForm)
        XCTAssertEqual(sut.entryType, .freeForm)
    }

    func test_init_withEntry_loadsContent() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx, content: "Today was a good day.")
        let sut = JournalViewModel(entry: entry)
        XCTAssertEqual(sut.content, "Today was a good day.")
    }

    func test_init_withEntry_loadsCreatedDate() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let fixedDate = Date(timeIntervalSince1970: 1_200_000)
        entry.createdDate = fixedDate
        let sut = JournalViewModel(entry: entry)
        XCTAssertEqual(sut.createdDate, fixedDate)
    }

    func test_init_withEntry_loadsEntryType() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx, entryType: .freeForm)
        let sut = JournalViewModel(entry: entry)
        XCTAssertEqual(sut.entryType, .freeForm)
    }

    func test_init_withEntry_nilContentFallsBackToEmptyString() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        entry.content = nil
        let sut = JournalViewModel(entry: entry)
        XCTAssertEqual(sut.content, "")
    }

    func test_init_withEntry_loadsPhotosFromPhotoEntities() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let image = makeImage()

        let photoEntity = PhotoEntity(context: ctx)
        photoEntity.imageData = image.jpegData(compressionQuality: 0.8)
        photoEntity.journalEntry = entry

        let sut = JournalViewModel(entry: entry)
        XCTAssertEqual(sut.selectedPhotos.count, 1)
    }

    func test_init_withEntry_ignoresPhotoEntitiesWithNilData() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)

        let photoEntity = PhotoEntity(context: ctx)
        photoEntity.imageData = nil
        photoEntity.journalEntry = entry

        let sut = JournalViewModel(entry: entry)
        XCTAssertTrue(sut.selectedPhotos.isEmpty)
    }

    // MARK: - removePhoto

    func test_removePhoto_removesMatchingPhoto() {
        let sut = JournalViewModel()
        let image = makeImage()
        sut.selectedPhotos = [image]
        sut.removePhoto(image)
        XCTAssertTrue(sut.selectedPhotos.isEmpty)
    }

    func test_removePhoto_leavesOtherPhotosIntact() {
        let sut = JournalViewModel()
        let imageA = makeImage(color: .red)
        let imageB = makeImage(color: .blue)
        sut.selectedPhotos = [imageA, imageB]
        sut.removePhoto(imageA)
        XCTAssertEqual(sut.selectedPhotos.count, 1)
        XCTAssertTrue(sut.selectedPhotos.contains(imageB))
    }

    func test_removePhoto_isNoOpWhenPhotoNotInArray() {
        let sut = JournalViewModel()
        let imageA = makeImage(color: .red)
        let imageB = makeImage(color: .blue)
        sut.selectedPhotos = [imageA]
        sut.removePhoto(imageB)   // imageB was never added
        XCTAssertEqual(sut.selectedPhotos.count, 1)
    }

    func test_removePhoto_onEmptyArray_doesNotCrash() {
        let sut = JournalViewModel()
        sut.selectedPhotos = []
        sut.removePhoto(makeImage())
        XCTAssertTrue(sut.selectedPhotos.isEmpty)
    }

    // MARK: - loadPhoto

    func test_loadPhoto_withEmptyItems_clearsSelectedPhotos() {
        let sut = JournalViewModel()
        sut.selectedPhotos = [makeImage()]  // pre-populate
        sut.loadPhoto(from: [])
        XCTAssertTrue(sut.selectedPhotos.isEmpty)
    }

    // MARK: - saveJournal — basic persistence

    func test_saveJournal_setsExistingEntry() {
        let ctx = makeInMemoryContext()
        let sut = JournalViewModel()
        sut.saveJournal(context: ctx)
        // Access via save(context:completion:) to keep existingEntry reachable
        // through the public API — verify a JournalEntry was created
        let request = NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
        let count = (try? ctx.fetch(request))?.count ?? 0
        XCTAssertEqual(count, 1)
    }

    func test_saveJournal_doesNotCreateDuplicateEntries() {
        let ctx = makeInMemoryContext()
        let sut = JournalViewModel()
        sut.saveJournal(context: ctx)
        sut.saveJournal(context: ctx)
        let request = NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
        let count = (try? ctx.fetch(request))?.count ?? 0
        XCTAssertEqual(count, 1)
    }

    func test_saveJournal_persistsContent() {
        let ctx = makeInMemoryContext()
        let sut = JournalViewModel()
        sut.content = "Reflections on the week."
        sut.saveJournal(context: ctx)
        let request = NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
        let result = try? ctx.fetch(request)
        XCTAssertEqual(result?.first?.content, "Reflections on the week.")
    }

    func test_saveJournal_callsOnSuccessCallback() {
        let ctx = makeInMemoryContext()
        let sut = JournalViewModel()
        var fired = false
        sut.saveJournal(context: ctx) { fired = true }
        XCTAssertTrue(fired)
    }

    func test_saveJournal_postsNotification() {
        let ctx = makeInMemoryContext()
        let sut = JournalViewModel()
        let expectation = XCTNSNotificationExpectation(
            name: NSNotification.Name("JournalEntrySaved")
        )
        sut.saveJournal(context: ctx)
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - saveJournal — photo handling

    func test_saveJournal_persistsPhotosWhenEntryTypeIsJournal() {
        let ctx = makeInMemoryContext()
        let sut = JournalViewModel()
        sut.entryType = .journal
        sut.selectedPhotos = [makeImage()]
        sut.saveJournal(context: ctx)

        let request = NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
        let count = (try? ctx.fetch(request))?.count ?? 0
        XCTAssertEqual(count, 1)
    }

    func test_saveJournal_doesNotPersistPhotosWhenEntryTypeIsNotJournal() {
        let ctx = makeInMemoryContext()
        let sut = JournalViewModel(initialEntryType: .freeForm)
        sut.selectedPhotos = [makeImage()]
        sut.saveJournal(context: ctx)

        let request = NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
        let count = (try? ctx.fetch(request))?.count ?? 0
        XCTAssertEqual(count, 0)
    }

    func test_saveJournal_replacesPhotosOnSubsequentSave() {
        let ctx = makeInMemoryContext()
        let sut = JournalViewModel()
        sut.entryType = .journal
        sut.selectedPhotos = [makeImage(color: .red), makeImage(color: .blue)]
        sut.saveJournal(context: ctx)

        // Replace with a single new photo
        sut.selectedPhotos = [makeImage(color: .green)]
        sut.saveJournal(context: ctx)

        let request = NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
        let count = (try? ctx.fetch(request))?.count ?? 0
        XCTAssertEqual(count, 1, "Old photos should be deleted and replaced, not appended")
    }

    func test_saveJournal_savesNoPhotoEntitiesWhenSelectedPhotosIsEmpty() {
        let ctx = makeInMemoryContext()
        let sut = JournalViewModel()
        sut.entryType = .journal
        sut.selectedPhotos = []
        sut.saveJournal(context: ctx)

        let request = NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
        let count = (try? ctx.fetch(request))?.count ?? 0
        XCTAssertEqual(count, 0)
    }

    // MARK: - Associated ItemEntity title fallback

    func test_saveJournal_usesUntitledEntryWhenTitleIsEmpty() {
        let ctx = makeInMemoryContext()
        let sut = JournalViewModel()
        sut.title = ""
        sut.saveJournal(context: ctx)

        let request = NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
        let result = try? ctx.fetch(request)
        XCTAssertEqual(result?.first?.title, "Untitled Entry")
    }

    func test_saveJournal_preservesNonEmptyTitle() {
        let ctx = makeInMemoryContext()
        let sut = JournalViewModel()
        sut.title = "A significant day"
        sut.saveJournal(context: ctx)

        let request = NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
        let result = try? ctx.fetch(request)
        XCTAssertEqual(result?.first?.title, "A significant day")
    }
}
