//
//  FloatingActionButton.swift
//  DoItAll
//
//  Created by Marc Harvey on 04/03/2026.
//

import SwiftUI

struct FloatingActionButton: View {
    let icon: String
    let colour: Color
    let delay: Double
    let action: () -> Void
    
    @StateObject private var viewModel = FloatingActionButtonViewModel()
    
    var body: some View {
        Button(action: { viewModel.handleTap(action: action) }) {
            ButtonContent(icon: icon, colour: colour, rotation: viewModel.rotation)
        }
        .buttonStyle(ScaleButtonStyle(isPresented: viewModel.isPressed,
                                      scale: viewModel.scale))
        .opacity(viewModel.opacity)
        .onAppear {
            viewModel.animateAppearance(delay: delay)
        }
        .onDisappear() {
            viewModel.resetAnimation()
        }
    }
}

// Button Content
private struct ButtonContent: View {
    let icon: String
    let colour: Color
    let rotation: Double
    
    var body: some View {
        ZStack {
            GradientCircleBackground(colour: colour, size: 50)
            
            Image(systemName: icon)
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .rotationEffect(.degrees(rotation))
        }
    }
}

private struct GradientCircleBackground: View {
    let colour: Color
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(gradient)
            .frame(width: size, height: size)
            .overlay(strokeOverlay)
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: [colour, colour.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom)
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

private struct ScaleButtonStyle: ButtonStyle {
    let isPresented: Bool
    let scale: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(isPresented ? 0.85 : scale)
    }
}
