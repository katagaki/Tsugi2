//
//  BusStop.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import Foundation

struct BusStop: Codable, Hashable {
    
    // Shared variables
    var code: String
    
    // BusArrivalv2 API
    var metadata: String?
    var arrivals: [BusService]?
    
    // BusStops API
    var roadName: String?
    var description: String?
    var latitude: Double?
    var longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case code = "BusStopCode"
        case metadata = "odata.metadata"
        case arrivals = "Services"
        case roadName = "RoadName"
        case description = "Description"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
    
}
