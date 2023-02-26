//
//  LocationUtilities.swift
//  Buses
//
//  Created by 堅書 on 26/2/23.
//

import CoreLocation
import Foundation

func distanceBetween(location: CLLocation, busStop: BusStop) -> Double {
    let busStopCoordinate = CLLocation(latitude: busStop.latitude ?? location.coordinate.latitude,
                                       longitude: busStop.longitude ?? location.coordinate.longitude)
    return location.distance(from: busStopCoordinate)
}
