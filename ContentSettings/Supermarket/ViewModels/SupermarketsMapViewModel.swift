//
//  SupermarketsMapViewModel.swift
//  DoItAll
//
//  Created by Marc Harvey on 02/04/2026.
//

import SwiftUI
import MapKit
import Combine

class SupermarketsMapViewModel: NSObject, ObservableObject {
    @Published var supermarkets: [Supermarket] = []
    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @Published var isSearching: Bool = false
    @Published var selectedSupermarketID: UUID?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func searchSupermarkets() {
        /// Request location permission
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func performSearch(around coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async {
            self.isSearching = true
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Supermarket"
        request.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isSearching = false
                
                if let error = error {
                    print("Search error: \(error)")
                }
                
                guard let response = response else { return }
                
                self.supermarkets = response.mapItems.map { item in
                    Supermarket(
                        name: item.name ?? "Supermarket",
                        coordinate: item.location.coordinate
                    )
                }
            }
        }
    }
}

extension SupermarketsMapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        locationManager.stopUpdatingLocation()
        performSearch(around: location.coordinate)
        
        /// Update camera position
        DispatchQueue.main.async {
            self.cameraPosition = .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location finding error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.isSearching = false
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied")
            DispatchQueue.main.async {
                self.isSearching = false
        }
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}

