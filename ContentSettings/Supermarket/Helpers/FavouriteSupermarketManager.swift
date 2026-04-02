//
//  FavouriteSupermarketManager.swift
//  DoItAll
//
//  Created by Marc Harvey on 29/03/2026.
//

import Foundation
import MapKit
import Combine
import UserNotifications
import UIKit

@MainActor
class FavouriteSupermarketManager: NSObject, ObservableObject {
    static let shared = FavouriteSupermarketManager()
    
    @Published var favouriteSupermarket: Supermarket?
    @Published var geofenceRadius: CLLocationDistance = 200 ///Default 200 metres
    @Published var notificationsPaused: Bool = false
    @Published var pauseUntilDate: Date?
    
    private let locationManager = CLLocationManager()
    private let userDefaults = UserDefaults.standard
    private let favouriteKey = "favouriteSupermarket"
    private let radiusKey = "geofenceRadius"
    private let pausedKey = "notificationsPaused"
    private let pausedUntilKey = "pauseUntilDate"
    private let geofenceIdentifier = "favouriteSupermarketGeofence"
    
    override init() {
        super.init()
        locationManager.delegate = self
        loadFavourite()
        loadRadius()
        loadPauseStatus()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Notification permission granted")
                } else if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
    }
    
    func setFavourite(_ supermarket: Supermarket) {
        // Remove old geofence if it exists
        if favouriteSupermarket != nil {
            removeGeofence()
        }
        
        // Save new favourite
        favouriteSupermarket = supermarket
        saveFavourite()
        
        // Setup geofence
        setupGeofence(for: supermarket)
        
        // Haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        print("Favourite supermarket is: \(supermarket.name)")
    }

    func removeFavourite() {
        removeGeofence()
        favouriteSupermarket = nil
        userDefaults.removeObject(forKey: favouriteKey)
        
        // Haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
        
        print("Removed favourite supermarket")
    }
    
    func isFavourite(_ supermarket: Supermarket) -> Bool {
        return favouriteSupermarket?.id == supermarket.id
    }
    
    private func saveFavourite() {
        guard let supermarket = favouriteSupermarket else { return }
        
        if let encoded = try? JSONEncoder().encode(supermarket) {
            userDefaults.set(encoded, forKey: favouriteKey)
        }
    }
    
    private func loadFavourite() {
        guard let data = userDefaults.data(forKey: favouriteKey),
              let supermarket = try? JSONDecoder().decode(Supermarket.self, from: data) else {
            return
        }
        
        favouriteSupermarket = supermarket
        setupGeofence(for: supermarket)
    }
    
    private func loadRadius() {
        let savedRadius = userDefaults.double(forKey: radiusKey)
        if savedRadius > 0 {
            geofenceRadius = savedRadius
        }
    }
    
    private func loadPauseStatus() {
        notificationsPaused = userDefaults.bool(forKey: pausedKey)
        if let pausedUntilDate = userDefaults.object(forKey: pausedUntilKey) as? Date {
            pauseUntilDate = pausedUntilDate
            
            if let pauseDate = pauseUntilDate, pauseDate < Date() {
                resumeNotifications()
            }
            
        }
    }
    
    func updateRadius(_ newRadius: CLLocationDistance) {
        geofenceRadius = newRadius
        userDefaults.set(newRadius, forKey: radiusKey)
        
        if let favourite = favouriteSupermarket {
            removeGeofence()
            setupGeofence(for: favourite)
        }
    }
    
    func pauseNotifications(for duration: TimeInterval) {
        notificationsPaused = true
        pauseUntilDate = Date().addingTimeInterval(duration)
        
        userDefaults.set(true, forKey: pausedKey)
        userDefaults.set(pauseUntilDate, forKey: pausedUntilKey)
        
        print("Notifications paused until \(pauseUntilDate?.formatted() ?? "unknown")")
    }
    
    func resumeNotifications() {
        notificationsPaused = false
        pauseUntilDate = nil
        
        userDefaults.set(false, forKey: pausedKey)
        userDefaults.removeObject(forKey: pausedUntilKey)
        
        print("Notifications resumed")
    }
    
    var isPaused: Bool {
        guard let pauseDate = pauseUntilDate else { return false }
        return notificationsPaused && pauseDate > Date()
    }
    
    private func setupGeofence(for supermarket: Supermarket) {
        locationManager.requestAlwaysAuthorization()
        
        let region = CLCircularRegion(
            center: supermarket.,
            radius: geofenceRadius,
            identifier: geofenceIdentifier)
        
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        locationManager.startMonitoring(for: region)
        print("Started monitoring geofence for \(supermarket.name)")
    }
    
    private func removeGeofence() {
        for region in locationManager.monitoredRegions {
            if region.identifier == geofenceIdentifier {
                locationManager.stopMonitoring(for: region)
                print("Stopped monitoring geofences")
            }
        }
    }
    
    private func sendNotification(for supermarket: Supermarket) {
        if isPaused {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Nearby supermarket"
        content.body = "Hey, you're close to your shop"
        content.sound = .default
        content.categoryIdentifier = "SUPERMARKET_NEARBY"
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification \(error.localizedDescription)")
            } else {
                print("Notification send successfully")
            }
        }
    }
}

extension FavouriteSupermarketManager: @MainActor CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region.identifier == geofenceIdentifier,
              let supermarket = favouriteSupermarket else {
            return
        }
        
        setupNotificationCategories()
        
        sendNotification(for: supermarket)
    }
    
    private func setupNotificationCategories() {
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "SUPERMARKET_NEARBY",
            actions: [dismissAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    private func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, with error: Error) {
        print("Monitoring failed for region: \(error.localizedDescription)")
    }
}
