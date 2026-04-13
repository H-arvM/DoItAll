//
//  SettingsViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 29/03/2026.
//

import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    let favouritesManager = FavouriteSupermarketManager.shared
    let themeManager = ThemeManager.shared
    
    func updateTheme(_ theme: BackgroundTheme) {
        themeManager.setTheme(theme)
    }
}
