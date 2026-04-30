//
//  PulsingDividerBar.swift
//  DoItAll
//
//  Created by Marc Harvey on 16/02/2026.
//

import SwiftUI

public struct PulsingDividerBar: View {
    @State private var hueRotation: Double = 0
    
    public var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .hueRotation(Angle(degrees: hueRotation))
            .onAppear {
                withAnimation(
                    .linear(duration: 10)
                    .repeatForever(autoreverses: false)
                ) {
                    hueRotation = 360
                }
            }
    }
}

#Preview {
    PulsingDividerBar()
}
