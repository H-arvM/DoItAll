//
//  ContentViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 05/04/2026.
//

import SwiftUI
import Combine
import CoreData

@MainActor
class ContentViewModel: NSObject, ObservableObject, ListViewModelProtocol, NSFetchedResultsControllerDelegate {
    
    @Published var items: [ItemEntity] = []
    @Published var selectedItem: ItemEntity?
    @Published var showAuthAlert: Bool = false
    @Published var authError: BiometricAuthManager.BiometricError?
    @Published var showOnboarding: Bool = false
    @Published var currentSortOption: SortOption = .dateCreated
    @Published var navigationPath = NavigationPath()
    
    public var isScrolling: Bool = false
    private var hideButtonsWorkItem: DispatchWorkItem?
    private var pendingItemToUnhide: NSManagedObjectID?
    
    private let viewContext: NSManagedObjectContext
    private let authManager = BiometricAuthManager()
    
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    private var fetchedResultsController: NSFetchedResultsController<ItemEntity>!
    
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @AppStorage("sortOption") private var sortOptionRawValue: String = SortOption.dateCreated.rawValue
    
    nonisolated init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        super.init()
    }
    
    func setupViewModel() {
        if let savedSort = SortOption(rawValue: sortOptionRawValue) {
            currentSortOption = savedSort
        }
        
        if fetchedResultsController == nil {
            setupFetchedResultsController()
        }
    }
    
    private func setupFetchedResultsController() {
        let request = NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
        request.sortDescriptors = getSortDescriptors()
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            self.items = fetchedResultsController.fetchedObjects ?? []
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    
    nonisolated func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let updatedItems = (controller.fetchedObjects as? [ItemEntity]) ?? []
        Task { @MainActor in
            self.items = updatedItems
        }
    }
    
    func loadItems() {
        self.items = fetchedResultsController.fetchedObjects ?? []
    }
    
    private func getSortDescriptors() -> [NSSortDescriptor] {
        switch currentSortOption {
        case .dateCreated:
            return [NSSortDescriptor(keyPath: \ItemEntity.createdAt, ascending: false)]
        case .type:
            return [NSSortDescriptor(keyPath: \ItemEntity.title, ascending: true),
                    NSSortDescriptor(keyPath: \ItemEntity.createdAt, ascending: true)]
        }
    }
    
    func setSortOption(_ option: SortOption) {
        currentSortOption = option
        sortOptionRawValue = option.rawValue
        
        fetchedResultsController.fetchRequest.sortDescriptors = getSortDescriptors()
        try? fetchedResultsController.performFetch()
        loadItems()
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    func handleHiddenItemTap(_ item: ItemEntity) {
        impactLight.prepare()
        
        authManager.authenticateUser(reason: "Authenticate to view hidden items") { [weak self] result in
            guard let self = self else { return }
            
            Task { @MainActor in
                switch result {
                case .success:
                    self.impactLight.impactOccurred()
                    self.navigationPath.append(
                        ItemNavigationDestination(itemID: item.objectID, itemType: item.itemType)
                    )
                case .failure(let error):
                    if case .userCancel = error { return }
                    self.notificationFeedback.prepare()
                    self.notificationFeedback.notificationOccurred(.error)
                }
            }
        }
    }
    
    func handleLongPress(for item: ItemEntity) {
        impactMedium.prepare()
        
        if item.isHidden {
            pendingItemToUnhide = item.objectID
            authManager.authenticateUser(reason: "Authenticate to unhide item") { [weak self] result in
                guard let self = self else { return }
                
                Task { @MainActor in
                    switch result {
                    case .success:
                        self.impactMedium.impactOccurred()
                        if let objectID = self.pendingItemToUnhide,
                           let itemToUnhide = try? self.viewContext.existingObject(with: objectID) as? ItemEntity {
                            itemToUnhide.isHidden = false
                            self.saveContext()
                            // FRC automatically updates the 'items' array here
                        }
                        self.pendingItemToUnhide = nil
                        
                    case .failure(let error):
                        if case .userCancel = error {
                            self.pendingItemToUnhide = nil
                            return
                        }
                        self.notificationFeedback.prepare()
                        self.notificationFeedback.notificationOccurred(.error)
                        self.authError = error
                        self.showAuthAlert = true
                        self.pendingItemToUnhide = nil
                    }
                }
            }
        } else {
            impactMedium.impactOccurred()
            item.isHidden = true
            saveContext()
        }
    }
    
    func checkOnboarding() {
        if !hasSeenOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showOnboarding = true
            }
        }
    }
    
    func isItemHidden(_ item: ItemEntity) -> Bool {
        return item.isHidden
    }
    
    var groupedItems: [ItemType: [ItemEntity]] {
        Dictionary(grouping: items) { $0.itemType }
    }
    
    var sortedItemTypes: [ItemType] {
        groupedItems.keys.sorted { $0.rawValue < $1.rawValue }
    }
    
    public func getShoppingListContent(_ entry: ShoppingEntry?) -> String {
        guard let entry = entry else { return "" }
        let itemsArray = (entry.items?.allObjects as? [ShoppingItem]) ?? []
        return itemsArray.first?.name ?? ""
    }
    
    public func getChecklistContent(_ entry: CheckListEntry?) -> String {
        guard let entry = entry else { return "No title" }
        let items = (entry.items?.allObjects as? [CheckListItem]) ?? []
        
        if !items.isEmpty {
            let sortedItems = items.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }
            if let firstNote = sortedItems.first?.note, !firstNote.isEmpty {
                return firstNote
            }
        }
        return entry.title ?? "No title"
    }
    
    func triggerSuccessHaptic() {
        impactMedium.prepare()
        impactMedium.impactOccurred()
    }
}
