//
//  OnboardingView.swift
//  DoItAll
//
//  Created by Marc Harvey on 05/03/2026.
//

import SwiftUI
import UIKit

struct OnboardingStep {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
}

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @Binding var dontShowAgain: Bool
    @State private var currentStep = 0
    @State private var showDontShowOption = false
    @Environment(\.colorScheme) var colourScheme
    
    let steps: [OnboardingStep] = [
        OnboardingStep(
            icon: "hand.tap.fill",
            title: "Tap to view",
            description: "Tap any row to view its details",
            accentColor: .blue
        ),
        OnboardingStep(
            icon: "hand.point.down.fill",
            title: "Long press to hide",
            description: "Press and hold on any row to hide it",
            accentColor: .purple
        ),
        OnboardingStep(
            icon: "eye.slash.fill",
            title: "Hidden and protected",
            description: "Hidden rows are marked with an 👁️ on the left",
            accentColor: .orange
        ),
        OnboardingStep(
            icon: "hand.rays.fill",
            title: "Long press to unhide",
            description: "Press and hold on the eye icon to unhide a row",
            accentColor: .indigo
        ),
        OnboardingStep(
            icon: "faceid",
            title: "Biometric security",
            description: "Use Face ID or Touch ID to access hidden content, unhide rows, or navigate into hidden items",
            accentColor: .indigo
        ),
        OnboardingStep(
            icon: "cart.fill",
            title: "Favourite supermarket",
            description: "Set your favourite supermarket and get notifications when you're nearby. Find this in the ⚙️",
            accentColor: .indigo
        ),
    ]
    
    var body: some View {
        ZStack {
            background
            
            VStack {
                stepCarousel
            }
            
            VStack {
                Spacer()
                pageIndicators
                    .padding(.bottom, 10)
                bottomActions
            }
        }
    }
        
    private var background: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.3),
                Color.purple.opacity(0.3),
                Color.orange.opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
        
    private var stepCarousel: some View {
        TabView(selection: $currentStep) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                OnboardingStepView(step: step)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxHeight: 500)
    }
        
    private var pageIndicators: some View {
        HStack(spacing: 8) {
            ForEach(0..<steps.count, id: \.self) { index in
                Circle()
                    .fill(currentStep == index ? primaryColor : primaryColor.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.top, 8)
    }
        
    private var bottomActions: some View {
        VStack(spacing: 5) {
            actionButton
            if currentStep == steps.count - 1 {
                doNotShowAgainToggle
                    .transition(.opacity.combined(with: .scale))
            }
        }
    }
    
    private var doNotShowAgainToggle: some View {
        Button {
            withAnimation {
                showDontShowOption.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: showDontShowOption ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(primaryColor)
                Text("Don't show this guide again")
                    .font(.subheadline)
                    .foregroundStyle(primaryColor)
            }
            .padding(.vertical, 8)
        }
    }
    
    private var actionButton: some View {
        Button {
            handleActionTap()
        } label: {
            Text(currentStep < steps.count - 1 ? "Next" : "Get started")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(actionButtonBackground)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 40)
    }
    
    private var actionButtonBackground: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Capsule()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
    }
    
    // MARK: - Helpers
    
    private var primaryColor: Color {
        colourScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.9)
    }
    
    private func handleActionTap() {
        if currentStep < steps.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                currentStep += 1
            }
        } else {
            if showDontShowOption { dontShowAgain = true }
            withAnimation { isPresented = false }
        }
    }
}

#Preview("Static bindings") {
    OnboardingView(isPresented: .constant(true), dontShowAgain: .constant(false))
}

#Preview("Interactive state") {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var isPresented: Bool = true
    @State private var dontShowAgain: Bool = false

    var body: some View {
        OnboardingView(isPresented: $isPresented, dontShowAgain: $dontShowAgain)
    }
}
