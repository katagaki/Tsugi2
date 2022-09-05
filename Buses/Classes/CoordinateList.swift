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
    
    func addCoordinate(from busStop: BusStop) {
        self.coordinates.append(Coordinate(busStop: busStop))
    }
    
    func addCoordinate(from newCoordinate: Coordinate) {
        self.coordinates.append(newCoordinate)
    }
    
    func removeAll() {
        self.coordinates.removeAll()
    }
}
