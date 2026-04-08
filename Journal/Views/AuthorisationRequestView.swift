//
//  AuthorisationRequestView.swift
//  DoItAll
//
//  Created by Marc Harvey on 29/03/2026.
//

import SwiftUI
import MusicKit

struct AuthorisationRequestView: View {
    let theme: BackgroundTheme
    let onRequestAccess: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note")
                .font(.system(size: 60))
                .foregroundStyle(theme.primaryColour)
            
            Text("Music Access Required")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Please grant access to Apple Music to search and add songs to your entry")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
            
            Button(action: onRequestAccess) {
                Text("Grant access")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 32)
                    .background(theme.primaryColour)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
    }
}

#Preview {
    AuthorisationRequestView(theme: .candy, onRequestAccess: {})
}
