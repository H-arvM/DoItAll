//
//  ThemeBackgroundView.swift
//  DoItAll
//
//  Created by Marc Harvey on 29/03/2026.
//

import SwiftUI

struct ThemeBackgroundView: View {
    let theme: BackgroundTheme
    
    var body: some View {
        switch theme {
        case .default:
            Color.clear
        case .synthWave:
            SynthWaveBackGroundView()
        case .sunset:
            SunsetBackgroundView()
        case .forest:
            ForestBackgroundView()
        case .midnight:
            MidnightBackgroundView()
        case .candy:
            CandyBackgroundView()
        }
    }
}

struct SynthWaveBackGroundView: View {
    @Environment(\.colorScheme) var colourScheme
    var body: some View {
        ZStack {
            // Base colour will adapt to mode
            colourScheme == .dark ? Color.black : Color(red: 0.95, green: 0.95, blue: 0.97)
            
            // Neon grid lines
            LinearGradient(
                colors: [
                    Color(red: 0.91, green: 0.12, blue: 0.84).opacity(colourScheme == .dark ? 0.15 : 0.08),
                    Color(red: 0.24, green: 0.88, blue: 0.82).opacity(colourScheme == .dark ? 0.15 : 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Glow from the bottom
            RadialGradient(
                colors: [
                    Color(red: 0.91, green: 0.12, blue: 0.84).opacity(colourScheme == .dark ? 0.25 : 0.12),
                    Color.clear
                ],
                center: .bottom,
                startRadius: 50,
                endRadius: 600
            )
            
            // Glow from the top
            RadialGradient(
                colors: [
                    Color(red: 0.25, green: 0.88, blue: 0.82).opacity(colourScheme == .dark ? 0.2 : 0.1),
                    Color.clear
                ],
                center: .top,
                startRadius: 100,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
    }
}

struct SunsetBackgroundView: View {
    @Environment(\.colorScheme) var colourScheme
    var body: some View {
        ZStack {
            // Neon grid lines
            LinearGradient(
                colors: colourScheme == .dark ? [
                    Color(red: 1.0, green: 0.6, blue: 0.4).opacity(0.3),
                    Color(red: 1.0, green: 0.45, blue: 0.2).opacity(0.2),
                    Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.15),
                ] : [
                    Color(red: 1.0, green: 0.85, blue: 0.7).opacity(0.4),
                    Color(red: 1.0, green: 0.7, blue: 0.5).opacity(0.3),
                    Color(red: 0.7, green: 0.5, blue: 0.8).opacity(0.2),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Warm glow
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.5, blue: 0.3).opacity(colourScheme == .dark ? 0.2 : 0.15),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
    }
}

struct ForestBackgroundView: View {
    @Environment(\.colorScheme) var colourScheme
    var body: some View {
        ZStack {
            // Base colour will adapt to mode
            colourScheme == .dark ?
            Color(red: 0.08, green: 0.12, blue: 0.08) :
            Color(red: 0.95, green: 0.94, blue: 0.92)
            
            // Green mist from the top
            LinearGradient(
                colors: [
                    Color(red: 0.13, green: 0.55, blue: 0.13).opacity(colourScheme == .dark ? 0.2 : 0.12),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .center
            )
            
            // Brown earth from the bottom
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(red: 0.55, green: 0.35, blue: 0.2).opacity(colourScheme == .dark ? 0.15 : 0.08),
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            
            // Glow from the top
            RadialGradient(
                colors: [
                    Color.white.opacity(colourScheme == .dark ? 0.1 : 0.4),
                    Color.clear
                ],
                center: .top,
                startRadius: 50,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }
}

struct MidnightBackgroundView: View {
    @Environment(\.colorScheme) var colourScheme
    
    var body: some View {
        ZStack {
            // Base colour will adapt to mode
            colourScheme == .dark ?
            Color(red: 0.05, green: 0.05, blue: 0.1) :
            Color(red: 0.85, green: 0.87, blue: 0.92)
            
            // Dark blue gradient
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.25, blue: 0.45).opacity(colourScheme == .dark ? 0.3 : 0.2),
                    Color.clear,
                    Color(red: 0.4, green: 0.2, blue: 0.6).opacity(colourScheme == .dark ? 0.2 : 0.12),

                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Stars effect
            RadialGradient(
                colors: [
                    Color.white.opacity(colourScheme == .dark ? 0.03 : 0.08),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 1,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
}

struct CandyBackgroundView: View {
    @Environment(\.colorScheme) var colourScheme
    
    var body: some View {
        ZStack {
            // Base colour will adapt to mode
            colourScheme == .dark ?
            Color(red: 0.15, green: 0.12, blue: 0.15) :
            Color(red: 0.99, green: 0.95, blue: 0.98)
            
            // Pink clouds
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.41, blue: 0.71).opacity(colourScheme == .dark ? 0.25 : 0.15),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 100,
                endRadius: 400
            )
            
            // Blue cotton candy
            RadialGradient(
                colors: [
                    Color(red: 0.53, green: 0.81, blue: 0.98).opacity(colourScheme == .dark ? 0.2 : 0.12),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 150,
                endRadius: 450
            )
            
            // Center highlight
            RadialGradient(
                colors: [
                    Color.white.opacity(colourScheme == .dark ? 0.15 : 0.5),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
}


#Preview {
    ThemeBackgroundView(theme: .candy)
}
