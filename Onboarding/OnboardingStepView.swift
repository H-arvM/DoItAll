//
//  OnboardingStepView.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/04/2026.
//

import SwiftUI

struct OnboardingStepView: View {
    let step: OnboardingStep
    @Environment(\.colorScheme) var colourScheme
    
    var body: some View {
        VStack(spacing: 30) {
            /// Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [step.accentColor.opacity(0.3),
                                     step.accentColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.5),
                                             Color.white.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.0
                            )
                    )
                Image(systemName: step.icon)
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [step.accentColor,
                                     step.accentColor.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .shadow(color: step.accentColor.opacity(0.3), radius: 20, x: 0, y: 10)
            
            /// TItle
            Text(step.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(colourScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.9))
                .multilineTextAlignment(.center)
            
            /// Description
            Text(step.description)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(colourScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.glassProminent)
        .padding()
    }
}

#Preview {
    OnboardingStepView(step: .init(icon: "🦄", title: "Test", description: "Test", accentColor: .red))
}
