//
//  HiddenIndicatorViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 26/03/2026.
//

import SwiftUI
import Combine

@MainActor
final class HiddenIndicatorViewModel: ObservableObject {
    @Published var shimmerOffset: CGFloat = -200
    
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    init() {
        hapticGenerator.prepare()
    }
    
    func handleLongPress(action: () -> Void) {
        hapticGenerator.impactOccurred()
        action()
    }
    
    func playShimmerAnimation(hasSeenBefore: Bool, onComplete: @escaping () -> Void) {
        guard !hasSeenBefore else { return }
        
        withAnimation(.linear(duration: HiddenIndicatorConstants.shimmerDuration)) {
            shimmerOffset =  HiddenIndicatorConstants.shimmerEndOffset
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + HiddenIndicatorConstants.shimmerDuration) {
            onComplete()
        }
    }
    
    func resetShimmer() {
        shimmerOffset = HiddenIndicatorConstants.shimmerStartOffset
    }
    
}

struct HiddenIndicatorConstants {
    static let shimmerWidth: CGFloat = 100
    static let shimmerStartOffset: CGFloat = -200
    static let shimmerEndOffset: CGFloat = 300
    static let shimmerDuration: Double = 2.0
    static let longPressDuration: Double = 0.5
}
