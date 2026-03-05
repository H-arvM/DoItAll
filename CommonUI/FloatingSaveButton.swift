//
//  FloatingSaveButton.swift
//  DoItAll
//
//  Created by Marc Harvey on 04/03/2026.
//

import SwiftUI

struct FloatingSaveButton: View {
    @State private var isPressed = false
    @State private var isPulsing = false
    @ObservedObject var settingsManager: SettingsManager

    var body: some View {
        NavigationLink(destination: NoteSelectionView(settingsManager: settingsManager)){
            ZStack{
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.5), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 2
                            )
                    )
                //Icon
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .scaleEffect(isPressed ? 0.85 : 1.0)
            .contentShape(.circle)
        }
        .simultaneousGesture(TapGesture().onEnded {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        })
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                isPulsing = true
            }
        }
    }
}
    
//    #Preview {
//        FloatingSaveButton()
//    }
