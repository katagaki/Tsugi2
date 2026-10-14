//
//  BusStopList.swift
//  Buses
//
//  Created by 堅書 on 2022/04/11.
//

import Foundation

class BusStopList: Codable, Hashable, ObservableObject, Identifiable {

    // BusStops API
    var metadata: String
    var busStops: [BusStop]

    init() {
        metadata = "created.from.init"
        busStops = []
    }

    enum CodingKeys: String, CodingKey {
        case metadata = "odata.metadata"
        case busStops = "value"
    }

    static func == (lhs: BusStopList, rhs: BusStopList) -> Bool {
        // Lists are reference types that are mutated in place, so compare by identity
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

}
