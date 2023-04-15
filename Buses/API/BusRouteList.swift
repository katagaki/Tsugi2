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
    var combinedBusRoutes: String?
    
    init() {
        metadata = "created.from.init"
        busRoutePoints = []
        combinedBusRoutes = busRoutePoints.reduce("", { partialResult, busRoutePoint in
            partialResult + "\(busRoutePoint.serviceNo).\(busRoutePoint.stopCode)"
        })
    }
    
    enum CodingKeys: String, CodingKey {
        case metadata = "odata.metadata"
        case busRoutePoints = "value"
    }
    
    static func == (lhs: BusRouteList, rhs: BusRouteList) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(combinedBusRoutes!)
    }
    
}
