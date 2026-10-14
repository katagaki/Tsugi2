//
//  CoordinateManager.swift
//  Buses
//
//  Created by 堅書 on 2022/06/13.
//

import CoreLocation
import SwiftUI

@Observable
class CoordinateManager {

    var coordinates: [Coordinate] = []
    var routeCoordinates: [CLLocationCoordinate2D] = []
    var liveBuses: [LiveBus] = []
    /// The bus stop a route is being viewed from, which stands out from the rest of the route's stops.
    var highlightedBusStopCode: String?
    var updateCameraFlag: Bool = false

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
        self.routeCoordinates.removeAll()
        self.liveBuses.removeAll()
        self.highlightedBusStopCode = nil
    }

}
