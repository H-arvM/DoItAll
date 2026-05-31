//
//  GroupHeader.swift
//  DoItAll
//
//  Created by Marc Harvey on 04/05/2026.
//

import SwiftUI

struct GroupHeader: View {
    @StateObject public var themeManager = ThemeManager.shared
    let type: ItemType
    @Binding var isExpanded: Bool
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: type.iconName)
                    .font(.system(size: 22))
                    .foregroundStyle(themeManager.selectedTheme.iconColour)
                    .frame(width: 30)
                
                Text(type.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .secondary)
                    .rotationEffect(.degrees(isExpanded ? 0 : -90))
            }
            .frame(height: 50)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GroupHeader(type: .freeFormType, isExpanded: .constant(true))
}
