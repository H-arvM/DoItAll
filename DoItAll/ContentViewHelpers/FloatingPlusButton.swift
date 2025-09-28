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
        NavigationLink(destination: NoteSelectionView(settingsManager: settingsManager)) {
            Image(systemName: "plus")
                .font(.system(size: 25))
                .padding()
                .shadow(radius: 5)
        }
        .glassEffect()
        .padding(.leading, 10)
        .padding(.bottom, 10)
    }
}

//#Preview {
//    
//    FloatingPlusButton(settingsManager: settingsManager)
//}
