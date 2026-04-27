//
//  EmptyView.swift
//  DoItAll
//
//  Created by Marc Harvey on 22/04/2026.
//

import SwiftUI

struct PlaceHolderContentView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "brain")
                .font(.system(size: 50, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .blue.opacity(0.1), radius: 10, x: 0, y: 5)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyView()
}
