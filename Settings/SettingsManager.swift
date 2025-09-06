//
//  SettingsManager.swift
//  DoItAll
//
//  Created by Marc Harvey on 06/09/2025.
//

import Foundation

class SettingsManager: ObservableObject {
    @Published var hidePreview: Bool = false
    @Published var emptyBool: Bool = false
    @Published var isNewEntryHidden: Bool = false
}
