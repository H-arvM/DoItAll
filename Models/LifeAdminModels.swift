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
    case bills = "Bills"
    case medical = "Medical"
    case insurance = "Insurance"
    case taxes = "Taxes"
    case home = "Home"
    case vehicle = "Vehicle"
    case subscriptions = "Subscriptions"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .bills: return "dollarsign.circle.fill"
        case .medical: return "cross.circle.fill"
        case .insurance: return "shield.fill"
        case .taxes: return "doc.text.fill"
        case .home: return "house.fill"
        case .vehicle: return "car.fill"
        case .subscriptions: return "repeat.circle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bills: return .green
        case .medical: return .red
        case .insurance: return .blue
        case .taxes: return .purple
        case .home: return .orange
        case .vehicle: return .cyan
        case .subscriptions: return .pink
        case .other: return .gray
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
