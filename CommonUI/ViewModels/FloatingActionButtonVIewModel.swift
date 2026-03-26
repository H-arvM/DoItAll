//
//  FloatingActionButtonVIewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 25/03/2026.
//

import SwiftUI
import UIKit

final class FloatingActionButtonViewModel: ObservableObject {
    @Published var isPressed: Bool = false
    @Published var scale: CGFloat = 0
    @Published var rotation: Double = -200
    @Published var opacity: Double = 0
    
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    private let config: AnimationConfig
    
    init(config: AnimationConfig = .default) {
        self.config = config
        hapticGenerator.prepare()
    }
    
    func handleTap(action: () -> Void) {
        triggerHaptic()
        animatePress()
        action()
    }
    
    func animateAppearance(delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                self.scale = 1.0
                self.opacity = 1.0
            }
                          
             withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                self.rotation = 0.0
            }
        }
    }
    
    func resetAnimation() {
        scale = 0.0
        opacity = 0.0
        rotation = -180.0
    }
    
    private func triggerHaptic() {
        hapticGenerator.impactOccurred()
    }
    
    private func animatePress() {
        withAnimation(.spring(response: config.springResponse, dampingFraction: config.dampingFraction)) {
            self.isPressed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + config.pressAnimationDuration) { [weak self] in
            withAnimation(.spring(response: self?.config.springResponse ?? 0.3, dampingFraction: self?.config.dampingFraction ?? 0.6)) {
                self?.isPressed = false
            }
        }
    }
}

struct AnimationConfig {
    let springResponse: Double
    let dampingFraction: Double
    let pressAnimationDuration: Double
    let appearDelay: Double
    
    static let `default` = AnimationConfig(
        springResponse: 0.3,
        dampingFraction: 0.6,
        pressAnimationDuration: 0.1,
        appearDelay: 0)
}
