//
//  ToolbarButtons.swift
//  DoItAll
//
//  Created by Marc Harvey on 06/09/2025.
//

import SwiftUI

struct ToolbarButtons: ToolbarContent {
    @Binding var showingSettings: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "slider.vertical.3")
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
        }
    }
}

//#Preview {
//    ToolbarButtons(showingSettings: false)
//}
