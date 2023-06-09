//
//  Coordinate.swift
//  Buses
//
//  Created by 堅書 on 2022/06/13.
//

import CoreLocation
import SwiftUI

class Coordinate: ObservableObject, Identifiable {

    var id: String {
        return busStop.code
    }
    @Published var busStop: BusStop = BusStop(code: "", description: "")
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0

    init(busStop: BusStop) {
        self.busStop = busStop
        self.latitude = busStop.latitude ?? 0.0
        self.longitude = busStop.longitude ?? 0.0
    }

    func clCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

}
