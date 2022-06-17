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
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        let combinedBusStopCodes: String = busStops.reduce("") { $0 + $1.code }
        hasher.combine(combinedBusStopCodes)
    }
    
}
