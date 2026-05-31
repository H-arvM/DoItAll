//
//  EntryTypeButton.swift
//  DoItAll
//
//  Created by Marc Harvey on 08/04/2026.
//

import SwiftUI

struct EntryTypeButton: View {
    let icon: String
    let title: String
    let colour: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [colour, colour.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 36))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.systemBackground)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("EntryTypeButton Preview") {
    EntryTypeButton(
        icon: "checkmark.circle.fill",
        title: "New Task",
        colour: .blue,
        action: {}
    )
    .padding()
    .previewLayout(.sizeThatFits)
}
