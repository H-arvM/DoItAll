//
//  SupermarketSelectionCard.swift
//  DoItAll
//
//  Created by Marc Harvey on 02/04/2026.
//

import SwiftUI
import CoreLocation

struct SupermarketSelectionCard: View {
    let supermarket: Supermarket
    let isFavourite: Bool
    let onSetFavourite: () -> Void
    let onRemoveFavourite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "cart.fill")
                    .font(.title2)
                    .foregroundStyle(isFavourite ? .green : .orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(supermarket.name)
                        .font(.headline)
                    
                    if isFavourite {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                            Text("Your favourite")
                                .font(.caption)
                        }
                        .foregroundStyle(.green)
                    }
                }
                Spacer()
                
                if isFavourite {
                    Button(action: onRemoveFavourite) {
                        Text("Remove")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.red)
                            .cornerRadius(8)
                    }
                } else {
                    Button(action: onSetFavourite) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                            Text("Set as Favourite")
                        }
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing)
                        )
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 16)
    }
}

#Preview {
    SupermarketSelectionCard(
        supermarket: .init(name: "Sample Market", coordinate: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)),
        isFavourite: true,
        onSetFavourite: {},
        onRemoveFavourite: {}
    )
}
