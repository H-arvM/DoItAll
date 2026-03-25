//
//  NoteListViewViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 04/03/2026.
//

import Foundation
import Combine
import UIKit
import SwiftUI
import CoreData

@MainActor
class NoteListViewViewModel: ObservableObject {
    @Published var hiddenItems: Set<NSManagedObjectID> = []
    @Published var selectedItem: Item?
    @Published var showAuthAlert = false
    @Published var authError: BiometricAuthManager.BiometricError?
    @Published var navigationPath = NavigationPath()
    
    private var pendingItemToHide: UUID?
    private let authManager = BiometricAuthManager()
    private let notification = UINotificationFeedbackGenerator()
    private let impact = UIImpactFeedbackGenerator(style: .rigid)
    private let hiddenKey = "hiddenItemURIs"
    
    func navigateTo(_ item: Item) {
        navigationPath.append(item)
    }
    
    @AppStorage("hiddenItemIDs") private var hiddenItemIDsData: Data = Data()
    
    init() {
       
    }
    
    func loadHiddenItems(context: NSManagedObjectContext) {
        guard let uris = UserDefaults.standard.array(forKey: hiddenKey) as? [String] else { return }
        let coordinator = context.persistentStoreCoordinator
        hiddenItems = Set(uris.compactMap { uriString -> NSManagedObjectID? in
            guard let url = URL(string: uriString),
                  let objectID = coordinator?.managedObjectID(forURIRepresentation: url)
            else { return nil }
            return objectID
        })
    }
    
    func saveHiddenItems() {
        let uris = hiddenItems.map { $0.uriRepresentation().absoluteString }
        UserDefaults.standard.set(uris, forKey: hiddenKey)
    }
    
    func handleHiddenItemTap(_ item: Item) {
        authManager.authenticateUser(reason: "Authenticate to view hidden item") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.impact.impactOccurred()
                    self.selectedItem = item
                }
                
            case .failure(let error):
                if case .userCancel = error { return }
                
                DispatchQueue.main.async {
                    self.notification.notificationOccurred(.error)
                    self.authError = error
                    self.showAuthAlert = true
                }
            }
        }
    }
    
    func handleLongPress(for objectID: NSManagedObjectID) {
        if hiddenItems.contains(objectID) {
            authManager.authenticateUser(reason: "Authenticate to unhide item") { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    notification.notificationOccurred(.success)
                    Task { @MainActor in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.hiddenItems.remove(objectID)
                        }
                        self.saveHiddenItems()
                    }
                case .failure(let error):
                    if case .userCancel = error { return }
                    Task { @MainActor in
                        self.notification.notificationOccurred(.error)
                        self.authError = error
                        self.showAuthAlert = true
                    }
                }
            }
        } else {
            impact.impactOccurred()
            withAnimation(.easeInOut(duration: 0.3)) {
                hiddenItems.insert(objectID)
            }
            saveHiddenItems()
        }
    }
}
