//
//  HiddenIndicatorView.swift
//  DoItAll
//
//  Created by Marc Harvey on 04/03/2026.
//

import SwiftUI

struct HiddenIndicatorView: View {
    let onLongPress: () -> Void
    @State private var scale: CGFloat = 0
    @State private var rotation: Double = 180
    @State private var opacity: Double = 0
    @State private var hasAnimated = false
    
    var body: some View {
        HStack {
            Image(systemName: "eye.slash.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 5)
                .background(
                    ZStack {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.6), .purple.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blur(radius: 4)
                            .scaleEffect(1.1)
                            .opacity(0.6)
                        
                        // Main gradient
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                )
                .padding(.leading, 16)
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)
                .onLongPressGesture(minimumDuration: 0.5) {
                    onLongPress()
                }
            
            Spacer()
        }
        .onAppear {
            if !hasAnimated {
                hasAnimated = true
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration:0)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration:0)) {
                    rotation = 0
                }
            } else {
                scale = 1.0
                opacity = 1.0
                rotation = 0
            }
        }
        .onDisappear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration:0)) {
                    scale = 0
                    opacity = 0
                    rotation = 180
                }
            }
        }
    }
}

//#Preview {
//    HiddenIndicatorView()
//}
