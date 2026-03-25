//
//  AnimatedActionButton.swift
//  DoItAll
//
//  Created by Marc Harvey on 16/02/2026.
//

import SwiftUI

struct AnimatedActionButton: View {
    let systemImage: String
    let action: () -> Void
    var color: Color = .blue
    var font: Font = .title2
    var symbolEffect: SymbolEffectType = .pulse
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .applySymbolEffect(symbolEffect)
                .font(font)
                .foregroundStyle(color)
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    enum SymbolEffectType {
        case pulse
        case bounce
        case none
    }
}

// Helper extension to apply the correct symbol effect
private extension Image {
    @ViewBuilder
    func applySymbolEffect(_ effectType: AnimatedActionButton.SymbolEffectType) -> some View {
        switch effectType {
        case .pulse:
            self.symbolEffect(.pulse, options: .nonRepeating)
        case .bounce:
            self.symbolEffect(.bounce, options: .nonRepeating)
        case .none:
            self
        }
    }
}

//#Preview {
//    AnimatedActionButton(systemImage: <#String#>, action: <#() -> Void#>)
//}
