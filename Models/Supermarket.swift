//
//  Supermarket.swift
//  DoItAll
//
//  Created by Marc Harvey on 25/03/2026.
//

import Foundation
import MapKit

struct Supermarket: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    
    var coordanates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: UUID, name: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    static func == (lhs: Supermarket, rhs: Supermarket) -> Bool {
        lhs.id == rhs.id
    }
}
