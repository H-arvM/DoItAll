//
//  NavigationArrowView.swift
//  DoItAll
//
//  Created by Marc Harvey on 04/03/2026.
//

import SwiftUI

struct NavigationArrowView: View {
    let onTap: () -> Void
    @State private var scale: CGFloat = 0
    @State private var rotation: Double = -180
    @State private var opacity: Double = 0
    @State private var hasAnimated = false
    @Environment(\.colorScheme) var colourScheme
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            
            Button(action: onTap) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(colourScheme == .dark ? Color.white.opacity(0.8) : Color.gray.opacity(0.9))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            .frame(height: 100)
            .padding(.trailing, 8)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
        }
        .onAppear {
            if !hasAnimated {
                hasAnimated = true
                withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0)) {
                    scale = 1.0
                    opacity = 1.0
                }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                    rotation = 0.0
                }
            } else {
                scale = 1.0
                opacity = 1.0
                rotation = 0.0
            }
        }
        .onDisappear {
            /// Reverse the animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                    scale = 1.0
                    opacity = 1.0
                    rotation = -180
                }
            }
        }
    }
}

//#Preview {
//    NavigationArrowView()
//}
