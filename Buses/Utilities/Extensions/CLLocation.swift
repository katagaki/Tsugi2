//
//  CLLocation.swift
//  Buses
//
//  Created by 堅書 on 26/2/23.
//

import CoreLocation
import Foundation

extension CLLocation {
    
    func distanceTo(busStop: BusStop) -> Double {
        let busStopCoordinate = CLLocation(latitude: busStop.latitude ?? self.coordinate.latitude,
                                           longitude: busStop.longitude ?? self.coordinate.longitude)
        return self.distance(from: busStopCoordinate)
    }
    
}
