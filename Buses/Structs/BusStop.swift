//
//  BusStop.swift
//  Buses
//
//  Created by 堅書 on 2022/04/11.
//

import Foundation

struct BusStop: Codable, Hashable {
    
    var code: String?
    var roadName: String?
    var description: String?
    var latitude: Double?
    var longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case code = "BusStopCode"
        case roadName = "RoadName"
        case description = "Description"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
    
}
