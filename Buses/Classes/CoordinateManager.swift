//
//  CoordinateManager.swift
//  Buses
//
//  Created by 堅書 on 2022/06/13.
//

import CoreLocation
import SwiftUI

class CoordinateManager: ObservableObject {

    @Published var coordinates: [Coordinate] = []
    @Published var polyline: String?
    @Published var updateCameraFlag: Bool = false

    func addCoordinate(from busStop: BusStop) {
        self.coordinates.append(Coordinate(busStop: busStop))
    }

    func addCoordinate(from newCoordinate: Coordinate) {
        self.coordinates.append(newCoordinate)
    }

    func replaceWithCoordinates(from busStops: [BusStop]) {
        var newCoordinates: [Coordinate] = []
        for busStop in busStops {
            newCoordinates.append(Coordinate(busStop: busStop))
        }
        self.coordinates = newCoordinates
    }

    func removeAll() {
        self.coordinates.removeAll()
        self.polyline = nil
    }

}
