//
//  DisplayedCoordinates.swift
//  Buses
//
//  Created by 堅書 on 2022/06/13.
//

import CoreLocation
import SwiftUI

class DisplayedCoordinates: ObservableObject {
    @Published var coordinates: [DisplayedCoordinate]
    
    init() {
        coordinates = []
    }
    
    init(coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = []
        for coordinate in coordinates {
            self.coordinates.append(DisplayedCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
    }
    
    func addCoordinate(from newCoordinate: CLLocationCoordinate2D) {
        self.coordinates.append(DisplayedCoordinate(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude))
    }
    
    func addCoordinate(from newCoordinate: DisplayedCoordinate) {
        self.coordinates.append(newCoordinate)
    }
    
    func removeAll() {
        self.coordinates.removeAll()
    }
}
