//
//  Coordinate.swift
//  Buses
//
//  Created by 堅書 on 2022/06/13.
//

import CoreLocation
import SwiftUI

class Coordinate: ObservableObject, Identifiable {
    var busStop: BusStop
    @Published var latitude: Double
    @Published var longitude: Double
    
    init(busStop: BusStop) {
        self.busStop = busStop
        self.latitude = busStop.latitude ?? 0.0
        self.longitude = busStop.longitude ?? 0.0
    }
    
    func updateCoordinates(to newCoordinate: CLLocationCoordinate2D) {
        self.latitude = newCoordinate.latitude
        self.longitude = newCoordinate.longitude
    }
    
    func clCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
