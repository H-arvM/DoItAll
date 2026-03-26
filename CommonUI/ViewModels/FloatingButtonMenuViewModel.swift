//
//  FloatingButtonMenuViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 25/03/2026.
//

import SwiftUI

@MainActor
final class FloatingButtonMenuViewModel: ObservableObject {
    @Published var isExpanded: Bool = false
    @Published var showSettings: Bool = false

    func toggleMenu() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            isExpanded.toggle()
        }
    }
    
    func closeMenu() {
        withAnimation {
            isExpanded = false
        }
    }
    
    func openSettings() {
        withAnimation {
            showSettings = true
            closeMenu()
        }
    }
}
