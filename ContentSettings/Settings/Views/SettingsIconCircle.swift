//
//  SettingsIconCircle.swift
//  DoItAll
//
//  Created by Marc Harvey on 31/03/2026.
//

import SwiftUI

struct SettingsIconCircle: View {
    let icon: String
    let colours: [Color]
    let size: CGFloat
    
    init(icon: String, colours: [Color], size: CGFloat = 40) {
        self.icon = icon
        self.colours = colours
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(gradient)
                .frame(width: size, height: size)
            
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white)
        }
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: colours,
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }
}

#Preview {
    SettingsIconCircle(icon: "arrow", colours: [.red, .green], size: 30)
}
