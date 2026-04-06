//
//  SwipeToDeleteRow.swift
//  DoItAll
//
//  Created by Marc Harvey on 06/04/2026.
//

import SwiftUI

struct SwipeToDeleteRow<Content: View>: View {
    let onDelete: () -> Void
    let content: () -> Content
    
    @State private var offset: CGFloat = 0
    @State private var isDeleting = false

    var body: some View {
        content()
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged{ value in
                        let translation = value.translation.width
                        if translation < 0 {
                            offset = translation
                        }
                    }
                    .onEnded { value in
                        let translation = value.translation.width
                        
                        if translation < -100 {
                            withAnimation(.easeOut(duration: 0.3)) {
                                offset = -UIScreen.main.bounds.width
                                isDeleting = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onDelete()
                            }
                        } else {
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
            )
            .clipped()
    }
}

#Preview("SwipeToDeleteRow") {
    SwipeToDeleteRow(onDelete: {}) {
        Text("Swipe me to delete")
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
    }
    .padding()
}
