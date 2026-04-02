//
//  SupermarketsMapView.swift
//  DoItAll
//
//  Created by Marc Harvey on 02/04/2026.
//

import SwiftUI
import MapKit

struct SupermarketsMapView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SupermarketsMapViewModel()
    @StateObject private var favouritesManager = FavouriteSupermarketManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedSupermarketID) {
                    UserAnnotation()
                    
                    ForEach(viewModel.supermarkets) { supermarket in
                        Marker(supermarket.name, systemImage: "cart.fill", coordinate: supermarket.coordinate)
                            .tint(favouritesManager.isFavourite(supermarket) ? .green : .orange)
                            .tag(supermarket.id)
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                
                if viewModel.isSearching {
                    VStack {
                        ProgressView("Searching for supermarkets...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                }
                
                // Selection card at bottom
                if let selectedId = viewModel.selectedSupermarketID,
                   let selected = viewModel.supermarkets.first(where: { $0.id == selectedId }) {
                    VStack{
                        Spacer()
                        SupermarketSelectionCard(
                            supermarket: selected,
                            isFavourite: favouritesManager.isFavourite(selected),
                            onSetFavourite: {
                                favouritesManager.setFavourite(selected)
                            },
                            onRemoveFavourite: {
                                favouritesManager.removeFavourite()
                            }
                            )
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Nearby supermarkets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.searchSupermarkets()
                favouritesManager.requestNotificationPermission()
            }
        }
    }
}

#Preview {
    SupermarketsMapView()
}
