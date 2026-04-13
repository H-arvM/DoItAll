//
//  SupermarketSettingsViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 02/04/2026.
//

import SwiftUI
import CoreLocation
import Combine

@MainActor
class SupermarketSettingsViewModel: ObservableObject {
    @Published var showSupermarketsMap: Bool = false
    @Published var showRadiusPicker: Bool = false
    @Published var showPausePicker: Bool = false
    
    let favouritesManager = FavouriteSupermarketManager.shared
    let themeManager = ThemeManager.shared
    let radiusOptions: [CLLocationDistance] = [100, 200, 300, 500, 1000]
    
    var favouriteSupermarket: Supermarket? {
        favouritesManager.favouriteSupermarket
    }
    
    var geofenceRadius: CLLocationDistance {
        favouritesManager.geofenceRadius
    }
    
    var isPaused: Bool {
        favouritesManager.isPaused
    }
    
    var pausedUntilDate: Date? {
        favouritesManager.pauseUntilDate
    }
    
    var primaryTextColour: Color {
        themeManager.selectedTheme.primaryColour
    }
    
    var secondaryTextColor: Color {
        themeManager.selectedTheme.secondaryTextColour ?? .secondary
    }
    
    func removeFavourite() {
        withAnimation {
            favouritesManager.removeFavourite()
        }
    }
    
    func updateRadius(_ radius: CLLocationDistance) {
        favouritesManager.updateRadius(radius)
    }
    
    func pauseNotifications(for duration: TimeInterval) {
        favouritesManager.pauseNotifications(for: duration)
    }
    
    func resumeNotifications() {
        favouritesManager.resumeNotifications()
    }

}
