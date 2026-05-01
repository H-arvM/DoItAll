//
//  CancelButton.swift
//  DoItAll
//
//  Created by Marc Harvey on 27/04/2026.
//

import SwiftUI

struct CancelButton: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button("Cancel") {
            dismiss()
        }
        .font(.footnote)
        .foregroundStyle(themeManager.selectedTheme.primaryColour)
    }
}

#Preview {
    CancelButton()
}
