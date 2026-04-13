//
//  GlassMorphicBackground.swift
//  DoItAll
//
//  Created by Marc Harvey on 04/03/2026.
//

import SwiftUI

struct GlassMorphicBackground: View {
    @State private var isPulsing: Bool = false
    @State private var isDisappearing: Bool = false
    @Environment(\.colorScheme) var colourScheme
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        ZStack {
            baseMaterial
            themeTint
            lightRefraction
            depthShadow
            glassBorders
            innerGlow
        }
        .shadow(color: Color.black.opacity(colourScheme == .dark ? 0.3 : 0.08),
                radius: 12, x: 0, y: 6)
        .shadow(color: themeManager.selectedTheme.secondaryColour.opacity(isPulsing ? 0.12 : 0.1),
                radius: 8, x: 0, y: 4)
    }

    // MARK: - View Components

    @ViewBuilder
    private var baseMaterial: some View {
        Rectangle()
            .fill(colourScheme == .dark ? .ultraThinMaterial : .thinMaterial)
            .opacity(isPulsing ? 0.98 : 0.95)
        
        if colourScheme == .light {
            Rectangle()
                .fill(Color.gray.opacity(0.15))
        }
    }

    @ViewBuilder
    private var themeTint: some View {
        let colours = colourScheme == .dark ? [
            themeManager.selectedTheme.primaryColour.opacity(isPulsing ? 0.25 : 0.22),
            themeManager.selectedTheme.secondaryColour.opacity(isPulsing ? 0.18 : 0.15),
            themeManager.selectedTheme.primaryColour.opacity(isPulsing ? 0.15 : 0.12)
        ] : [
            themeManager.selectedTheme.primaryColour.opacity(isPulsing ? 0.28 : 0.25),
            themeManager.selectedTheme.secondaryColour.opacity(isPulsing ? 0.23 : 0.2),
            themeManager.selectedTheme.primaryColour.opacity(isPulsing ? 0.21 : 0.18)
        ]
        
        Rectangle()
            .fill(LinearGradient(colors: colours, startPoint: .topLeading, endPoint: .bottomTrailing))
            .blendMode(.softLight)
    }

    @ViewBuilder
    private var lightRefraction: some View {
        let colours = colourScheme == .dark ? [
            Color.white.opacity(isPulsing ? 0.25 : 0.2),
            Color.white.opacity(isPulsing ? 0.15 : 0.1),
            Color.clear,
            Color.clear
        ] : [
            Color.white.opacity(isPulsing ? 0.35 : 0.3),
            Color.white.opacity(isPulsing ? 0.2 : 0.15),
            Color.clear,
            Color.clear
        ]

        Rectangle()
            .fill(LinearGradient(colors: colours, startPoint: .topLeading, endPoint: .center))
            .blendMode(.overlay)
    }

    @ViewBuilder
    private var depthShadow: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .clear, Color.white.opacity(isPulsing ? 0.15 : 0.12)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .blendMode(.multiply)
    }

    @ViewBuilder
    private var glassBorders: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(topBorderGradient)
                .frame(height: 1.5)
                .blur(radius: 0.5)
            
            Spacer()
            
            // Bottom border
            Rectangle()
                .fill(bottomBorderGradient)
                .frame(height: 1)
                .blur(radius: 0.8)
        }
    }

    @ViewBuilder
    private var innerGlow: some View {
        VStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: colourScheme == .dark ?
                            [Color.white.opacity(isPulsing ? 0.15 : 0.12), .clear] :
                            [Color.white.opacity(isPulsing ? 0.25 : 0.2), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 3)
                .blur(radius: 2)
            Spacer()
        }
    }

    // MARK: - Helper Gradients

    private var topBorderGradient: LinearGradient {
        let whiteEdgeOpacity: Double = isPulsing ? 0.5 : 0.45
        let whiteMidLow = Color.white.opacity(0.3)

        let themeMid: Color = themeManager.selectedTheme.primaryColour.opacity(colourScheme == .dark ? 0.5 : 0.4)

        let edgeWhite = Color.white.opacity(whiteEdgeOpacity)

        let colours: [Color]
        if colourScheme == .dark {
            colours = [
                edgeWhite,
                whiteMidLow,
                themeMid,
                whiteMidLow,
                edgeWhite
            ]
        } else {
            let whiteEdgeLightOpacity: Double = isPulsing ? 0.75 : 0.7
            let edgeWhiteLight = Color.white.opacity(whiteEdgeLightOpacity)
            let whiteMid = Color.white.opacity(0.5)
            colours = [
                edgeWhiteLight,
                whiteMid,
                themeMid,
                whiteMid,
                edgeWhiteLight
            ]
        }

        return LinearGradient(colors: colours, startPoint: .leading, endPoint: .trailing)
    }

    private var bottomBorderGradient: LinearGradient {
        let colours: [Color]
        if colourScheme == .dark {
            let side = Color.white.opacity(0.2)
            let mid = themeManager.selectedTheme.secondaryColour.opacity(isPulsing ? 0.45 : 0.4)
            colours = [side, mid, side]
        } else {
            let left = Color.white.opacity(0.3)
            let mid = themeManager.selectedTheme.secondaryColour.opacity(isPulsing ? 0.35 : 0.3)
            let right = Color.white.opacity(0.2)
            colours = [left, mid, right]
        }
        return LinearGradient(colors: colours, startPoint: .leading, endPoint: .trailing)
    }
}

struct GlassMorphicMaterial: View {
    let isPulsing: Bool
    @Environment(\.colorScheme) var colourScheme

    var body: some View {
        Rectangle()
            .fill(colourScheme == .dark ? .ultraThinMaterial : .thinMaterial)
            .opacity(isPulsing ? 0.98 : 0.95)

        if colourScheme == .light {
            Rectangle()
                .fill(Color.gray.opacity(0.15))
        }
    }
}

struct GlassMorphicGradientTint: View {
    let isPulsing: Bool
    @Environment(\.colorScheme) var colourScheme

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: colourScheme == .dark ? [
                        Color.blue.opacity(isPulsing ? 0.25 : 0.22),
                        Color.purple.opacity(isPulsing ? 0.18 : 0.15),
                        Color.blue.opacity(isPulsing ? 0.15 : 0.12)
                    ] : [
                        Color.blue.opacity(isPulsing ? 0.28 : 0.25),
                        Color.purple.opacity(isPulsing ? 0.23 : 0.2),
                        Color.blue.opacity(isPulsing ? 0.21 : 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blendMode(.softLight)
    }
}

struct GlassMorphicLightRefraction: View {
    let isPulsing: Bool
    @Environment(\.colorScheme) var colourScheme

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: colourScheme == .dark ? [
                        Color.white.opacity(isPulsing ? 0.25 : 0.2),
                        Color.white.opacity(isPulsing ? 0.15 : 0.1),
                        Color.clear,
                        Color.clear,
                    ] : [
                        Color.white.opacity(isPulsing ? 0.35 : 0.3),
                        Color.white.opacity(isPulsing ? 0.2 : 0.15),
                        Color.clear,
                        Color.clear,
                    ],
                    startPoint: .topLeading,
                    endPoint: .center
                )
            )
            .blendMode(.overlay)
    }
}

struct GlassMorphicDepthShadow: View {
    @Environment(\.colorScheme) var colourScheme

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.clear,
                        Color.black.opacity(colourScheme == .dark ? 0.15 : 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .blendMode(.multiply)
    }
}

struct GlassMorphicBorders: View {
    let isPulsing: Bool
    @Environment(\.colorScheme) var colourScheme

    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: colourScheme == .dark ? [
                            Color.white.opacity(isPulsing ? 0.5 : 0.45),
                            Color.white.opacity(0.3),
                            Color.blue.opacity(0.5),
                            Color.white.opacity(0.3),
                            Color.white.opacity(isPulsing ? 0.5 : 0.45),
                        ] : [
                            Color.white.opacity(isPulsing ? 0.75 : 0.7),
                            Color.white.opacity(0.5),
                            Color.blue.opacity(0.4),
                            Color.white.opacity(0.5),
                            Color.white.opacity(isPulsing ? 0.75 : 0.7),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1.5)
                .blur(radius: 0.5)

            Spacer()

            // Bottom border
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: colourScheme == .dark ? [
                            Color.white.opacity(0.2),
                            Color.white.opacity(isPulsing ? 0.45 : 0.4),
                            Color.white.opacity(0.2),
                        ] : [
                            Color.white.opacity(0.3),
                            Color.white.opacity(isPulsing ? 0.35 : 0.3),
                            Color.white.opacity(0.3),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .blur(radius: 0.8)
        }
    }
}

struct GlassMorphicInnerGlow: View {
    let isPulsing: Bool
    @Environment(\.colorScheme) var colourScheme

    var body: some View {
        VStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: colourScheme == .dark ? [
                            Color.white.opacity(isPulsing ? 0.15 : 0.12),
                            Color.clear,
                        ] : [
                            Color.white.opacity(isPulsing ? 0.25 : 0.2),
                            Color.clear,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 3)
                .blur(radius: 2)
            Spacer()
        }
    }
}

//#Preview {
//    GlassMorphicBackground()
//}

