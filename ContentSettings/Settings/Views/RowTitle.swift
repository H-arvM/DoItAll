//
//  RowTitle.swift
//  DoItAll
//
//  Created by Marc Harvey on 31/03/2026.
//

import SwiftUI

struct RowTitle: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    RowTitle(title: "Test title")
}
