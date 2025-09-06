//
//  FloatingPlusButton.swift
//  DoItAll
//
//  Created by Marc Harvey on 06/09/2025.
//

import SwiftUI

struct FloatingPlusButton: View {
    @ObservedObject var settingsManager: SettingsManager
    
    var body: some View {
        NavigationLink(destination: NewNoteView(settingsManager: settingsManager)) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.purple)
                .padding()
                .shadow(radius: 10)
        }
        .padding(.leading, 10)
        .padding(.bottom, 10)
    }
}

//#Preview {
//    
//    FloatingPlusButton(settingsManager: settingsManager)
//}
