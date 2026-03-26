//
//  HiddenIndicatorView.swift
//  DoItAll
//
//  Created by Marc Harvey on 04/03/2026.
//

import SwiftUI

struct HiddenIndicatorView: View {
    let onLongPress: () -> Void
    
    @StateObject private var viewModel = HiddenIndicatorViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @AppStorage("hasSeenHiddenIndicatorAnimation") private var hasSeenAnimation: Bool = false
    
    var body: some View {
        HStack {
            IconButton(
                gradientColours: themeManager.selectedTheme.gradientColours,
                shimmerOffset: viewModel.shimmerOffset,
                onLongPress: { viewModel.handleLongPress(action: onLongPress) }
            )
            
            Spacer()
        }
        .onAppear {
            viewModel.playShimmerAnimation(hasSeenBefore: hasSeenAnimation) {
                hasSeenAnimation = true
            }
        }
    }
}

// Hidden Icon Button (👁️ icon)
private struct IconButton: View {
    let gradientColours: [Color]
    let shimmerOffset: CGFloat
    let onLongPress: () -> Void
    
    var body: some View {
        Image(systemName: "eye.slash.fill")
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                AnimatedGradientBackground(
                    gradientColours: gradientColours,
                    shimmerOffset: shimmerOffset
                )
            )
            .onLongPressGesture(minimumDuration: 0.5) {
                onLongPress()
            }
    }
}

// Animated gradient background
private struct AnimatedGradientBackground: View {
    let gradientColours: [Color]
    let shimmerOffset: CGFloat
    
    var body: some View {
        ZStack {
            GlowRing(colours: gradientColours)
            GradientCapsule(colours: gradientColours)
            ShimmerOverlay(offset: shimmerOffset)
        }
    }
}

// Glow ring
private struct GlowRing: View {
    let colours: [Color]
    
    var body: some View {
        Capsule()
            .fill(gradient)
            .blur(radius: 4)
            .scaleEffect(0.1)
            .opacity(0.6)
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: colours.map { $0.opacity(0.6) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// Gradient capsule
private struct GradientCapsule: View {
    let colours: [Color]
    
    var body: some View {
        Capsule()
            .fill(gradient)
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: colours,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// Shimmer Overlay
private struct ShimmerOverlay: View {
    let offset: CGFloat
    
    private let shimmerColours: [Color] = [
        .white.opacity(0),
        .white.opacity(0.3),
        .white.opacity(0.5),
        .white.opacity(0.3),
        .white.opacity(0),
    ]
    
    var body: some View {
        GeometryReader { geometry in
            Capsule()
                .fill(gradient)
                .frame(width: 100)
                .offset(x: offset)
        }
        .clipShape(Capsule())
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: shimmerColours,
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        HiddenIndicatorView(onLongPress: {
            print("Long press triggered")
        })
        
        HiddenIndicatorView(onLongPress: {})
            .padding()
    }
}
