//
//  FloatingArrowButton.swift
//  DoItAll
//
//  Created by Marc Harvey on 25/03/2026.
//

import SwiftUI

struct FloatingArrowButton: View {
    @StateObject private var viewModel = FloatingButtonMenuViewModel()
    @Binding var showSortOptions: Bool
    let currentSortOption: SortOption
    let onToggleSort: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            if viewModel.isExpanded {
                ExpandedActions(
                    onSettingsTap: viewModel.openSettings,
                    onSortTap: {
                        onToggleSort()
                        viewModel.closeMenu()
                    }
                )
            }
            
            MainFloatingButton(
                isExpanded: $viewModel.isExpanded,
                onTap: viewModel.toggleMenu
            )
        }
        .sheet(isPresented: $viewModel.showSettings) {
            EmptyView()
            // Insert new SettingsView() here later
        }
    }
}

struct ExpandedActions: View {
    let onSettingsTap: () -> Void
    let onSortTap: () -> Void
    
    private let transition = AnyTransition.asymmetric(
        insertion: .scale(scale: 0.1).combined(with: .opacity),
        removal: .scale(scale: 0.1).combined(with: .opacity)
    )
    
    var body: some View {
        Group {
            FloatingActionButton(
                icon: "gearshape",
                colour: .gray,
                delay: 0.0,
                action: onSettingsTap)
            
            FloatingActionButton(
                icon: "arrow.up.arrow.down",
                colour: .orange,
                delay: 0.0,
                action: onSortTap)
        }
        .transition(transition)
    }
}

// Main Floating button

struct MainFloatingButton: View {
    @Binding var isExpanded: Bool
    let onTap: () -> Void
    
    @StateObject private var viewModel = MainFloatingButtonViewModel()
    
    var body: some View {
        ZStack {
            GradientCircle()
            ButtonIcon(isExpanded: isExpanded)
        }
        .scaleEffect(viewModel.isPressed ? 0.85 : 1.0)
        .rotationEffect(.degrees(isExpanded ? 45 : 0))
        .contentShape(.circle)
        .onTapGesture {
            viewModel.handleTap(onTap: onTap)
        }
        .onAppear {
            viewModel.startPulsing()
        }
    }
}

struct GradientCircle: View {
    let size: CGFloat
    let colours: [Color]
    
    init(size: CGFloat = 60, colours: [Color] = [.blue, .purple]) {
        self.size = size
        self.colours = colours
    }
    
    var body: some View {
        Circle()
            .fill(gradient)
            .frame(width: size, height: size)
            .overlay(strokeOverlay)
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: colours,
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }
    
    private var strokeOverlay: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [.white.opacity(0.5), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 0
            )
    }
}

struct ButtonIcon: View {
    let isExpanded: Bool
    
    var body: some View {
        Image(systemName: iconName)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .rotationEffect(.degrees(isExpanded ? 315 : 0))
    }
    
    private var iconName: String {
        isExpanded ? "arrow.down" : "arrow.up"
    }
}

//#Preview {
//    FloatingArrowButton()
//}
