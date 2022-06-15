//
//  BusStopList.swift
//  Buses
//
//  Created by 堅書 on 2022/04/11.
//

import Foundation

struct BusStopList: Codable, Hashable {
    
    // BusStops API
    var metadata: String
    var busStops: [BusStop]
    
    enum CodingKeys: String, CodingKey {
        case metadata = "odata.metadata"
        case busStops = "value"
    }
    
}
