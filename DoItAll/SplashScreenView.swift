//
//  SplashScreenView.swift
//  DoItAll
//
//  Created by Marc Harvey on 08/04/2026.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var rotation: Double = -100
    @Environment(\.colorScheme) var colourScheme
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.4),
                         Color.purple.opacity(0.4),
                         Color.blue.opacity(0.3)
                        ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue.opacity(0.4),
                                     Color.purple.opacity(0.2),
                                     Color.clear
                                    ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 150
                            )
                        )
                    .frame(width: 300, height: 300)
                    .blur(radius: 30)
                
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.6),
                                             Color.white.opacity(0.2),
                                             Color.white.opacity(0.1)
                                            ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.00001
                            )
                    )
                
                Image(systemName: "brain")
                    .font(.system(size: 80, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
        }
        .buttonStyle(.glassProminent)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                rotation = 0.0
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
