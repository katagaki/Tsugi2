//
//  BABusStop.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import Foundation

struct BABusStop: Codable, Hashable {
    
    // Results from the call to http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2
    
    var metadata: String
    var code: String
    var busServices: [BABusService]
    
    enum CodingKeys: String, CodingKey {
        case metadata = "odata.metadata"
        case code = "BusStopCode"
        case busServices = "Services"
    }
    
}
