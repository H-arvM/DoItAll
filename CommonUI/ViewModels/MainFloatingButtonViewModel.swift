//
//  MainFloatingButtonViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 25/03/2026.
//

import SwiftUI
import Combine

@MainActor
final class MainFloatingButtonViewModel: ObservableObject {
    @Published var isPressed: Bool = false
    @Published var isPulsing: Bool = false
    
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    struct AnimationConfig{
        let pressResponse: Double
        let pressDamping: Double
        let pressDuration: Double
        let expandResponse: Double
        let expandDamping: Double
        
        static let `default` = AnimationConfig(
            pressResponse: 0.3,
            pressDamping: 0.6,
            pressDuration: 0.1,
            expandResponse: 0.5,
            expandDamping: 0.6)
    }
    
    private let config: AnimationConfig
    
    init(config: AnimationConfig = .default) {
        self.config = config
        hapticGenerator.prepare()
    }
    
    func handleTap(onTap: () -> Void) {
        triggerHaptic()
        animatePress()
        onTap()
    }
    
    func startPulsing() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            isPulsing = true
        }
    }
    
    private func triggerHaptic() {
        hapticGenerator.impactOccurred()
    }
    
    private func animatePress() {
        withAnimation(.spring(response: config.pressResponse,
                              dampingFraction: config.pressDamping)) {
            isPressed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + config.pressDuration) { [weak self] in
            guard let self else { return }
            
            withAnimation(.spring(response: config.pressResponse, dampingFraction: config.pressDamping)) {
                self.isPressed = false
            }
        }
    }
}
