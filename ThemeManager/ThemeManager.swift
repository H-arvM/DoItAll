//
//  ThemeManager.swift
//  DoItAll
//
//  Created by Marc Harvey on 25/03/2026.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var selectedTheme: BackgroundTheme = .default
    
    static let shared = ThemeManager()
    private let themeKey = "selectedBackgroundTheme"
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadTheme()
    }
    
    func setTheme(_ theme: BackgroundTheme) {
        selectedTheme = theme
        if let encoded = try? JSONEncoder().encode(theme) {
            userDefaults.set(encoded, forKey: themeKey)
            
        }
    }
    
    private func loadTheme() {
        guard let data = userDefaults.data(forKey: themeKey),
                let theme = try? JSONDecoder().decode(BackgroundTheme.self, from: data) else {
            return
        }
        selectedTheme = theme
    }
}

enum BackgroundTheme: String, CaseIterable, Codable {
    case `default` = "Default"
    case synthWave = "Synthave"
    case sunset = "Sunset"
    case forest = "Forest"
    case midnight = "Midnight"
    case candy = "Candy"
    
    var id: String { rawValue }
    
    var preferredColourScheme: ColorScheme? {
        return nil // Light/dark mode
    }
    
    var primaryTextColour: Color? {
        return nil // System .primary
    }
    
    var secondaryTextColour: Color? {
        return nil // System .primary
    }
    
    var primaryColour: Color {
        switch self {
        case .default:
            return .blue
        case .synthWave:
            return Color(red: 0.91, green: 0.12, blue: 0.84) // Neon magneta
        case .sunset:
            return Color(red: 1.0, green: 0.45, blue: 0.2) // Vibrant orange
        case .forest:
            return Color(red: 0.13, green: 0.55, blue: 0.13) // Forest green
        case .midnight:
            return Color(red: 0.2, green: 0.25, blue: 0.45) // Deep blue
        case .candy:
            return Color(red: 1.0, green: 0.41, blue: 0.71) // Hot pink
        }
    }
    
    var secondaryColour: Color {
        switch self {
        case .default:
            return .blue
        case .synthWave:
            return Color(red: 0.25, green: 0.12, blue: 0.84)
        case .sunset:
            return Color(red: 0.4, green: 0.2, blue: 0.6)
        case .forest:
            return Color(red: 0.55, green: 0.35, blue: 0.2)
        case .midnight:
            return Color(red: 0.4, green: 0.2, blue: 0.6)
        case .candy:
            return Color(red: 0.53, green: 0.81, blue: 0.98)
        }
    }
    
    var iconColour: Color {
        switch self {
        case .default:
            return .blue
        case .synthWave:
            return Color(red: 0.91, green: 0.12, blue: 0.84)
        case .sunset:
            return Color(red: 1.0, green: 0.45, blue: 0.2)
        case .forest:
            return Color(red: 0.13, green: 0.55, blue: 0.13)
        case .midnight:
            return Color(red: 0.2, green: 0.25, blue: 0.45)
        case .candy:
            return Color(red: 1.0, green: 0.41, blue: 0.71)
        }
    }
    
    var gradientColours: [Color] {
        switch self {
        case .default:
            return [.blue, .purple]
        case .synthWave:
            return [
                Color(red: 0.91, green: 0.12, blue: 0.84),
                Color(red: 0.25, green: 0.88, blue: 0.82)
            ]
        case .sunset:
            return [
                Color(red: 1.0, green: 0.45, blue: 0.2),
                Color(red: 0.4, green: 0.2, blue: 0.6)
            ]
        case .forest:
            return [
                Color(red: 0.13, green: 0.55, blue: 0.13),
                Color(red: 0.55, green: 0.35, blue: 0.2)
            ]
        case .midnight:
            return [
                Color(red: 0.2, green: 0.25, blue: 0.45),
                Color(red: 0.4, green: 0.2, blue: 0.6)
            ]
        case .candy:
            return [
                Color(red: 1.0, green: 0.41, blue: 0.71),
                Color(red: 0.53, green: 0.81, blue: 0.98)
            ]
        }
    }
}


