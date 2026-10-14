//
//  BusRouteList.swift
//  Buses
//
//  Created by 堅書 on 15/4/23.
//

import Foundation

class BusRouteList: Codable, Hashable, ObservableObject, Identifiable {

    var metadata: String
    var busRoutePoints: [BusRoutePoint]

    init() {
        metadata = "created.from.init"
        busRoutePoints = []
    }

    enum CodingKeys: String, CodingKey {
        case metadata = "odata.metadata"
        case busRoutePoints = "value"
    }

    static func == (lhs: BusRouteList, rhs: BusRouteList) -> Bool {
        // Lists are reference types that are mutated in place, so compare by identity
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

}
