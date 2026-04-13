//
//  SettingsNavigationRow.swift
//  DoItAll
//
//  Created by Marc Harvey on 31/03/2026.
//

import SwiftUI

struct SettingsNavigationRow<Destination: View>: View {
    let icon: String
    let title: String
    let iconColours: [Color]
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                SettingsIconCircle(
                    icon: icon,
                    colours: iconColours
                    )
                
                RowTitle(title: title)
                
                Spacer()
            }
            .padding(.vertical, 5)
        }
    }
}

#Preview {
    SettingsNavigationRow(icon: "Test", title: "Test", iconColours: [.gray, .red], destination: EmptyView())
}
