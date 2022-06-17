//
//  Coordinate.swift
//  Buses
//
//  Created by 堅書 on 2022/06/13.
//

import CoreLocation
import SwiftUI

class Coordinate: ObservableObject, Identifiable {
    @Published var latitude: Double
    @Published var longitude: Double
    
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func updateCoordinates(to newCoordinate: CLLocationCoordinate2D) {
        self.latitude = newCoordinate.latitude
        self.longitude = newCoordinate.longitude
    }
    
    func clCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
