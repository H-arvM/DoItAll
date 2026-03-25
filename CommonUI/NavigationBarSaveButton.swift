//
//  NavigationBarSaveButton.swift
//  DoItAll
//
//  Created by Marc Harvey on 04/03/2026.
//

import SwiftUI

struct NavigationBarSaveButton: View {
    let action: () -> Void
    
    @State private var isPressed = false
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(colors: [.blue, .purple],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
            Image(systemName: "square.and.arrow.down.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 36, height: 36) //Maybe increase later?
        .scaleEffect(isPressed ? 0.85 : 1.0)
        .contentShape(Circle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            action()
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
}

//#Preview {
//    NavigationBarSaveButton()
//}
