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
class ContentViewModel: ObservableObject {
    @Published var items: [ItemEntity] = []
    @Published var selectedItem: ItemEntity?
    @Published var showAuthAlert: Bool = false
    @Published var authError: BiometricAuthManager.BiometricError?
    @Published var showOnboarding: Bool = false
    @Published var currentSortOption: SortOption = .dateCreated
    @Published var scrollMinDisplacement: CGFloat = 12
    @Published var scrollMinVelocity: CGFloat = 50
    @Published var scrollRequiredConsecutiveHits: Int = 2
    
    @State private var lastScrollTime: TimeInterval = 0
    @State private var consecutiveVelocityHits: Int = 0
    @State public var scrollDetectionEnabled: Bool = false
    @State private var scrollOffSet: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State public var isScrolling: Bool = false
    @State private var hideButtonsWorkItem: DispatchWorkItem?
    
    private var pendingItemToUnhide: NSManagedObjectID?
    private let authManager = BiometricAuthManager()
    private let viewContext: NSManagedObjectContext
    
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @AppStorage("sortOption") private var sortOptionRawValue: String = SortOption.dateCreated.rawValue
    
    nonisolated init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
    }
    
    func setupViewModel() {
        if let savedSort = SortOption(rawValue: sortOptionRawValue) {
            currentSortOption = savedSort
        }
        
        loadItems()
    }
    
    // Core Data Management
    func loadItems() {
        let request = NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
        request.sortDescriptors = getSortDescriptors()
        
        do {
            items = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch items \(error)")
            items = []
        }
    }
    
    private func getSortDescriptors() -> [NSSortDescriptor] {
        switch currentSortOption {
        case .dateCreated:
            return [NSSortDescriptor(keyPath: \ItemEntity.createdAt, ascending: false)]
        case .type:
            return [NSSortDescriptor(keyPath: \ItemEntity.title, ascending: true),
                    NSSortDescriptor(keyPath: \ItemEntity.createdAt, ascending: true)
                    ]
        }
    }
    
    func setSortOption(_ option: SortOption) {
        currentSortOption = option
        sortOptionRawValue = option.rawValue
        loadItems()
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                print("Context saved successfully")
            } catch {
                print("Failed to save context: \(error)")
            }
        } else {
            print("No changes to save")
        }
    }
    
    @MainActor
    func handleHiddenItemTap(_ item: ItemEntity) {
        authManager.authenticateUser(reason: "Authenticate to view hidden items") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                Task { @MainActor in
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    self.selectedItem = item
                }
                
            case .failure(let error):
                if case .userCancel = error { return }
                Task { @MainActor in
                    let notification = UINotificationFeedbackGenerator()
                    notification.notificationOccurred(.error)
                }
            }
        }
    }
    
    func handleLongPress(for item: ItemEntity) {
        if item.isHidden {
            pendingItemToUnhide = item.objectID
            authManager.authenticateUser(reason: "Authenticate to unhide item") { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    /// Auth success so unhide the item
                    if let objectID = self.pendingItemToUnhide {
                        if let item = try? self.viewContext.existingObject(with: objectID) as? ItemEntity {
                            item.isHidden = false
                            self.saveContext()
                            self.viewContext.refreshAllObjects()
                            self.loadItems()
                        }
                        self.pendingItemToUnhide = nil
                    }
                    
                case .failure(let error):
                    /// Only show error for non-cancellation errors
                    if case .userCancel = error {
                        self.pendingItemToUnhide = nil
                        return
                    }
                    
                    let notification = UINotificationFeedbackGenerator()
                    notification.notificationOccurred(.error)
                    
                    self.authError = error
                    self.showAuthAlert = true
                    self.pendingItemToUnhide =  nil
                }
            }
        } else {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            /// No auth needed for hiding an item
            item.isHidden = true
            saveContext()
            viewContext.refreshAllObjects()
            loadItems()
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
        Dictionary(grouping: items) { item in
            item.itemType
        }
    }
    
    var sortedItemTypes: [ItemType] {
        groupedItems.keys.sorted { $0.rawValue < $1.rawValue }
    }
    
    public func handleScroll(offset: CGFloat) {
        let now = CACurrentMediaTime()
        let timeDelta = now - lastScrollTime
        let delta = offset - lastScrollOffset

        // Update lastScrollOffset/time for next calculation
        lastScrollOffset = offset
        lastScrollTime = now

        // Ignore until detection is enabled to avoid initial layout
        if !scrollDetectionEnabled {
            return
        }

        // Guard against extremely small time deltas (first run or same frame)
        if timeDelta <= 0 {
            return
        }

        // Compute absolute velocity (points per second)
        let velocity = abs(delta) / CGFloat(timeDelta)

        // Tunable thresholds
        let minDisplacement: CGFloat = scrollMinDisplacement
        let minVelocity: CGFloat = scrollMinVelocity
        let requiredConsecutiveHits = scrollRequiredConsecutiveHits

        let qualifies = abs(delta) > minDisplacement && velocity > minVelocity

        if qualifies {
            consecutiveVelocityHits += 1
            if consecutiveVelocityHits >= requiredConsecutiveHits {
                withAnimation {
                    isScrolling = true
                }
            }
        } else {
            consecutiveVelocityHits = 0
        }

        hideButtonsWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            withAnimation {
                self.isScrolling = false
            }
            self.consecutiveVelocityHits = 0
        }
        hideButtonsWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

    
}
