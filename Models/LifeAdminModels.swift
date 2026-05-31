//
//  LifeAdminModels.swift
//  DoItAll
//
//  Created by Marc Harvey on 20/04/2026.
//

import Foundation
import SwiftUI

// MARK: - Task Category Enum
enum TaskCategory: String, CaseIterable, Codable {
    case home = "Home"
    case bills = "Bills"
    case medical = "Medical"
    case insurance = "Insurance"
    case taxes = "Taxes"
    case vehicle = "Vehicle"
    case subscriptions = "Subscriptions"
    case dependents = "Dependents"
    case misc = "Miscellaneous"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .bills: return "banknote"
        case .medical: return "cross.circle.fill"
        case .insurance: return "shield.fill"
        case .taxes: return "doc.text.fill"
        case .vehicle: return "car.fill"
        case .subscriptions: return "repeat.circle.fill"
        case .dependents: return "teddybear"
        case .misc: return "questionmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return .orange
        case .bills: return .green
        case .medical: return .red
        case .insurance: return .blue
        case .taxes: return .purple
        case .vehicle: return .cyan
        case .subscriptions: return .pink
        case .dependents: return .indigo
        case .misc: return .gray
        }
    }
}

// MARK: - Life Admin Task Model
struct LifeAdminTask: Identifiable {
    let id = UUID()
    var title: String
    var category: TaskCategory
    var dueDate: Date
    var isCompleted: Bool
}
