//
//  CoordinateList.swift
//  Buses
//
//  Created by 堅書 on 2022/06/13.
//

import CoreLocation
import SwiftUI

class CoordinateList: ObservableObject {
    @Published var coordinates: [Coordinate]
    
    init() {
        coordinates = []
    }
    
    init(coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = []
        for coordinate in coordinates {
            self.coordinates.append(Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
    }
    
    func addCoordinate(from newCoordinate: CLLocationCoordinate2D) {
        self.coordinates.append(Coordinate(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude))
    }
    
    func addCoordinate(from newCoordinate: Coordinate) {
        self.coordinates.append(newCoordinate)
    }
    
    func removeAll() {
        self.coordinates.removeAll()
    }
}
