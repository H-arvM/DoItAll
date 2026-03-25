//
//  SortOptions.swift
//  DoItAll
//
//  Created by Marc Harvey on 25/03/2026.
//

import Foundation

enum SortOption: String, CaseIterable {
    case dateCreated = "Date Created"
    case type = "Type"
    
    var systemImage: String {
        switch self {
        case .dateCreated:
            return "clock.circle.fill"
        case .type:
            return "folder.circle.fill"
        }
    }
}
