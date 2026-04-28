//
//  CollapsedPhotosView.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/04/2026.
//

import SwiftUI

struct CollapsedPhotosView: View {
    @ObservedObject var viewModel: JournalViewModel
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(viewModel.selectedPhotos.prefix(4), id: \.self) { photo in
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                if viewModel.selectedPhotos.count > 4 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.selectedTheme.primaryColour)
                            .frame(width: 80, height: 80)
                        
                        Text("+\(viewModel.selectedPhotos.count - 4)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                    }
                }
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
    }

}

//#Preview {
//    CollapsedPhotosView()
//}
