//
//  GlassMorphicBackground.swift
//  DoItAll
//
//  Created by Marc Harvey on 04/03/2026.
//

import SwiftUI

struct GlassMorphicBackground: View {
    var isPulsing: Bool = false
    @Environment(\.colorScheme) var colourScheme

    var body: some View {
        ZStack {
            GlassMorphicMaterial(isPulsing: isPulsing)
            GlassMorphicGradientTint(isPulsing: isPulsing)
            GlassMorphicLightRefraction(isPulsing: isPulsing)
            GlassMorphicDepthShadow()
            GlassMorphicBorders(isPulsing: isPulsing)
            GlassMorphicInnerGlow(isPulsing: isPulsing)
        }
        .shadow(color: Color.black.opacity(colourScheme == .dark ? 0.3 : 0.08), radius: 12, x: 0, y: 0)
        .shadow(color: Color.purple.opacity(isPulsing ? 0.12 : 0.1), radius: 8, x: 0, y: 4)
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
