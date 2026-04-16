//
//  ExpandedPhotosView.swift
//  DoItAll
//
//  Created by Marc Harvey on 13/04/2026.
//

import SwiftUI

struct ExpandedPhotosView: View {
    let mode: EditOrViewMode
    @ObservedObject var viewModel: JournalViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(viewModel.selectedPhotos, id: \.self) { photo in
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .if(condition: mode == .edit) { view in
                            view.contextMenu {
                                Button(role: .destructive) {
                                    viewModel.removePhoto(photo)
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
    }
}

extension View {
    @ViewBuilder
    func `if`<Transform: View>(condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
//
//#Preview {
//    ExpandedPhotosVIew()
//}
