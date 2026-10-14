//
//  LiveBus.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import CoreLocation
import SwiftUI

/// An incoming bus with a known position, shown on the map.
struct LiveBus: Identifiable {

    /// Position in the arrival list, which keeps annotations stable between refreshes so they animate.
    let id: Int
    let serviceNo: String
    let coordinate: CLLocationCoordinate2D
    let load: BusLoad?
    let type: BusType?

    var color: Color {
        switch load {
        case .standingAvailable: return .orange
        case .limitedStanding: return .red
        default: return .green
        }
    }

    var symbolName: String {
        type == .doubleDeck ? "bus.doubledecker.fill" : "bus.fill"
    }

    static func buses(of busService: BusService) -> [LiveBus] {
        [busService.nextBus, busService.nextBus2, busService.nextBus3]
            .enumerated()
            .compactMap { index, arrivalInfo in
                // LTA DataMall reports 0 when a bus has no position yet
                guard let arrivalInfo,
                      let latitude = arrivalInfo.latitudeAsDouble(), latitude != 0.0,
                      let longitude = arrivalInfo.longitudeAsDouble(), longitude != 0.0 else {
                    return nil
                }
                return LiveBus(id: index, serviceNo: busService.serviceNo,
                               coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                               load: arrivalInfo.load, type: arrivalInfo.type)
            }
    }

}
