//
//  LifeAdminViewModelTests.swift
//  DoItAllTests
//

import XCTest
import CoreData
@testable import DoItAll

@MainActor
final class LifeAdminViewModelTests: XCTestCase {
    
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
    
    private func makeEntry(context: NSManagedObjectContext) -> TaskEntry {
        let entry = TaskEntry(context: context)
        entry.id = UUID()
        entry.createdAt = Date()
        entry.entryType = EntryType.lifeAdmin.rawValue
        return entry
    }
    
    private func makeTask(
        context: NSManagedObjectContext,
        entry: TaskEntry,
        title: String = "Task",
        category: TaskCategory? = nil,
        sortOrder: Int32 = 0
    ) -> TaskItem {
        let task = TaskItem(context: context)
        task.id = UUID()
        task.title = title
        task.category = category?.rawValue
        task.isCompleted = false
        task.createdAt = Date()
        task.sortOrder = sortOrder
        task.taskEntry = entry
        return task
    }
    
    // MARK: - Initialisation
    
    func test_init_withNoEntry_hasEmptyDefaults() {
        let sut = LifeAdminViewModel()
        XCTAssertEqual(sut.itemName, "")
        XCTAssertEqual(sut.notes, "")
        XCTAssertNil(sut.existingEntry)
        XCTAssertNil(sut.selectedCategory)
        XCTAssertFalse(sut.hasDueDate)
    }
    
    func test_init_withNoEntry_respectsInitialEntryType() {
        let sut = LifeAdminViewModel(initialEntryType: .journal)
        XCTAssertEqual(sut.entryType, .journal)
    }
    
    func test_init_withEntry_loadsCreatedDate() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let fixedDate = Date(timeIntervalSince1970: 500_000)
        entry.createdAt = fixedDate
        let sut = LifeAdminViewModel(entry: entry)
        XCTAssertEqual(sut.createdDate, fixedDate)
    }
    
    func test_init_withEntry_loadsEntryType() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        entry.entryType = EntryType.freeForm.rawValue
        let sut = LifeAdminViewModel(entry: entry)
        XCTAssertEqual(sut.entryType, .freeForm)
    }
    
    func test_init_withEntry_loadsEntryID() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let sut = LifeAdminViewModel(entry: entry)
        XCTAssertEqual(sut.entryID, entry.id)
    }
    
    func test_init_withEntry_unknownEntryTypeFallsBackToLifeAdmin() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        entry.entryType = "unknownType"
        let sut = LifeAdminViewModel(entry: entry)
        XCTAssertEqual(sut.entryType, .lifeAdmin)
    }
    
    // MARK: - filteredTasks
    
    func test_filteredTasks_returnsAllTasksWhenNoCategorySelected() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let sut = LifeAdminViewModel(entry: entry)
        sut.tasks = [
            makeTask(context: ctx, entry: entry, category: .home),
            makeTask(context: ctx, entry: entry, category: .insurance)
        ]
        sut.selectedCategory = nil
        XCTAssertEqual(sut.filteredTasks.count, 2)
    }
    
    func test_filteredTasks_filtersToSelectedCategory() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let sut = LifeAdminViewModel(entry: entry)
        sut.tasks = [
            makeTask(context: ctx, entry: entry, category: .dependents),
            makeTask(context: ctx, entry: entry, category: .home),
            makeTask(context: ctx, entry: entry, category: .dependents)
        ]
        sut.selectedCategory = .dependents
        XCTAssertEqual(sut.filteredTasks.count, 2)
        XCTAssertTrue(sut.filteredTasks.allSatisfy { $0.category == TaskCategory.dependents.rawValue })
    }
    
    func test_filteredTasks_returnsEmptyWhenNoCategoryMatches() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let sut = LifeAdminViewModel(entry: entry)
        sut.tasks = [makeTask(context: ctx, entry: entry, category: .bills)]
        sut.selectedCategory = .medical
        XCTAssertTrue(sut.filteredTasks.isEmpty)
    }
    
    func test_filteredTasks_emptyTasksAlwaysReturnsEmpty() {
        let sut = LifeAdminViewModel()
        sut.tasks = []
        sut.selectedCategory = .misc
        XCTAssertTrue(sut.filteredTasks.isEmpty)
    }
    
    // MARK: - selectCategory
    
    func test_selectCategory_setsSelectedCategory() {
        let sut = LifeAdminViewModel()
        sut.selectCategory(.misc)
        XCTAssertEqual(sut.selectedCategory, .misc)
    }
    
    func test_selectCategory_deselectsWhenSameCategoryTapped() {
        let sut = LifeAdminViewModel()
        sut.selectCategory(.medical)
        sut.selectCategory(.medical)
        XCTAssertNil(sut.selectedCategory)
    }
    
    func test_selectCategory_switchesToNewCategory() {
        let sut = LifeAdminViewModel()
        sut.selectCategory(.medical)
        sut.selectCategory(.subscriptions)
        XCTAssertEqual(sut.selectedCategory, .subscriptions)
    }
    
    // MARK: - addTask
    
    func test_addTask_withEmptyName_doesNotCreateEntry() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        sut.itemName = ""
        sut.addTask(context: ctx)
        XCTAssertNil(sut.existingEntry)
    }
    
    func test_addTask_resetsFormAfterSaving() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        sut.itemName = "Chase solicitor"
        sut.notes = "Re: house purchase"
        sut.hasDueDate = true
        sut.dueDate = Date()
        sut.addTask(context: ctx)
        
        XCTAssertEqual(sut.itemName, "")
        XCTAssertEqual(sut.notes, "")
        XCTAssertFalse(sut.hasDueDate)
        XCTAssertNil(sut.dueDate)
        XCTAssertFalse(sut.showingAddTask)
    }
    
    func test_addTask_setsExistingEntry() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        sut.itemName = "Book MOT"
        sut.addTask(context: ctx)
        XCTAssertNotNil(sut.existingEntry)
    }
    
    func test_addTask_incrementsTaskCount() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        sut.itemName = "First task"
        sut.addTask(context: ctx)
        sut.itemName = "Second task"
        sut.addTask(context: ctx)
        XCTAssertEqual(sut.tasks.count, 2)
    }
    
    func test_addTask_setsDueDateWhenHasDueDateIsTrue() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        let expectedDate = Date(timeIntervalSinceNow: 86_400)
        sut.itemName = "Renew passport"
        sut.hasDueDate = true
        sut.dueDate = expectedDate
        sut.addTask(context: ctx)
        
        XCTAssertEqual(sut.tasks.first?.dueDate, expectedDate)
    }
    
    func test_addTask_nilsDueDateWhenHasDueDateIsFalse() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        sut.itemName = "No deadline task"
        sut.hasDueDate = false
        sut.dueDate = Date()     // set but should be ignored
        sut.addTask(context: ctx)
        
        XCTAssertNil(sut.tasks.first?.dueDate)
    }
    
    func test_addTask_storesNilNotesWhenNotesIsEmpty() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        sut.itemName = "Silent task"
        sut.notes = ""
        sut.addTask(context: ctx)
        XCTAssertNil(sut.tasks.first?.notes)
    }
    
    func test_addTask_preservesNonEmptyNotes() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        sut.itemName = "Task with notes"
        sut.notes = "Remember to bring ID"
        sut.addTask(context: ctx)
        XCTAssertEqual(sut.tasks.first?.notes, "Remember to bring ID")
    }
    
    func test_addTask_assignsSortOrderByCurrentTaskCount() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        sut.itemName = "Task A"
        sut.addTask(context: ctx)
        sut.itemName = "Task B"
        sut.addTask(context: ctx)
        
        let sortOrders = sut.tasks.map { $0.sortOrder }.sorted()
        XCTAssertEqual(sortOrders, [0, 1])
    }
    
    // MARK: - toggleTaskCompletion
    
    func test_toggleTaskCompletion_flipsToTrue() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let task = makeTask(context: ctx, entry: entry)
        task.isCompleted = false
        let sut = LifeAdminViewModel(entry: entry)
        sut.toggleTaskCompletion(task, context: ctx)
        XCTAssertTrue(task.isCompleted)
    }
    
    func test_toggleTaskCompletion_flipsBackToFalse() {
        let ctx = makeInMemoryContext()
        let entry = makeEntry(context: ctx)
        let task = makeTask(context: ctx, entry: entry)
        task.isCompleted = true
        let sut = LifeAdminViewModel(entry: entry)
        sut.toggleTaskCompletion(task, context: ctx)
        XCTAssertFalse(task.isCompleted)
    }
    
    // MARK: - saveAdminEntry
    
    func test_saveAdminEntry_returnsNonNilUUID() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        let id = sut.saveAdminEntry(context: ctx)
        XCTAssertNotNil(id)
    }
    
    func test_saveAdminEntry_setsExistingEntry() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        sut.saveAdminEntry(context: ctx)
        XCTAssertNotNil(sut.existingEntry)
    }
    
    func test_saveAdminEntry_setsEntryID() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        let returned = sut.saveAdminEntry(context: ctx)
        XCTAssertEqual(sut.entryID, returned)
    }
    
    func test_saveAdminEntry_callsOnSuccessCallback() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        var fired = false
        sut.saveAdminEntry(context: ctx) { fired = true }
        XCTAssertTrue(fired)
    }
    
    func test_saveAdminEntry_returnsSameIDOnSubsequentCalls() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        let first = sut.saveAdminEntry(context: ctx)
        let second = sut.saveAdminEntry(context: ctx)
        XCTAssertEqual(first, second)
    }
    
    // MARK: - postSaveNotification
    
    func test_saveAdminEntry_postsNotification() {
        let ctx = makeInMemoryContext()
        let sut = LifeAdminViewModel()
        let expectation = XCTNSNotificationExpectation(
            name: NSNotification.Name("LifeAdminEntrySaved")
        )
        sut.saveAdminEntry(context: ctx)
        wait(for: [expectation], timeout: 1.0)
    }
}
