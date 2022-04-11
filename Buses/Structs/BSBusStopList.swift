//
//  BSBusStopList.swift
//  Buses
//
//  Created by 堅書 on 2022/04/11.
//

import Foundation

struct BSBusStopList: Codable, Hashable {
    
    // Results from the call to http://datamall2.mytransport.sg/ltaodataservice/BusStops
    
    var metadata: String
    var busStops: [BusStop]
    
    enum CodingKeys: String, CodingKey {
        case metadata = "odata.metadata"
        case busStops = "value"
    }
    
}
