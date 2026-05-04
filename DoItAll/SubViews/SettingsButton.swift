//
//  SettingsButton.swift
//  DoItAll
//
//  Created by Marc Harvey on 04/05/2026.
//

import SwiftUI

protocol ListViewModelProtocol: ObservableObject {
    var currentSortOption: SortOption { get }
    var isScrolling: Bool { get }
    func setSortOption(_ option: SortOption)
}

struct SettingsButton<T: ListViewModelProtocol>: View {
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject var viewModel: T
    @State private var showSortOptions: Bool = false
    
    var body: some View {
        let theme = themeManager.selectedTheme
        
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                FloatingMenuButton(
                    showSortOptions: $showSortOptions,
                    currentSortOption: viewModel.currentSortOption,
                    onToggleSort: {
                        toggleSortOption()
                    }
                )
                .tint(theme.primaryColour)
                .padding(.leading, 20)
                .padding(.bottom, 20)
                
                Spacer()
            }
        }
        .offset(y: viewModel.isScrolling ? 200 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isScrolling)
        .ignoresSafeArea(.keyboard)
    }
    
    private func toggleSortOption() {
        let allOptions = SortOption.allCases
        if let currentIndex = allOptions.firstIndex(of: viewModel.currentSortOption) {
            let nextIndex = (currentIndex + 1) % allOptions.count
            viewModel.setSortOption(allOptions[nextIndex])
        }
    }
}

//#Preview {
//    SettingsButton()
//}
