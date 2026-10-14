//
//  ArrivalAttributes.swift
//  Buses
//
//  Created by 堅書 on 2026/10/14.
//

import ActivityKit
import Foundation

struct ArrivalAttributes: ActivityAttributes {

    struct ContentState: Codable, Hashable {
        var nextArrival: Date?
        var followingArrival: Date?
        var load: BusLoad?
        var type: BusType?
        var isWheelchairAccessible: Bool = false
        var updatedAt: Date = .now

        init(busService: BusService?) {
            nextArrival = busService?.nextBus?.estimatedArrivalTimeAsDate()
            followingArrival = busService?.nextBus2?.estimatedArrivalTimeAsDate()
            load = busService?.nextBus?.load
            type = busService?.nextBus?.type
            isWheelchairAccessible = busService?.nextBus?.feature == .wheelchairAccessible
        }
    }

    var serviceNo: String
    var busStopCode: String
    var busStopName: String
    var startedAt: Date = .now

}
