//
//  BABusOnRoad.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import Foundation

struct BABusOnRoad: Codable, Hashable {
    
    var firstBusStopCode: String
    var lastBusStopCode: String
    var estimatedArrivalTime: String // Actually Date
    var latitude: String // Actually Double
    var longitude: String // Actually Double
    var visitNumber: String // Actually Int
    var load: BusLoad
    var feature: BusFeature
    var type: BusType
    
    enum CodingKeys: String, CodingKey {
        case firstBusStopCode = "OriginCode"
        case lastBusStopCode = "DestinationCode"
        case estimatedArrivalTime = "EstimatedArrival"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case visitNumber = "VisitNumber"
        case load = "Load"
        case feature = "Feature"
        case type = "Type"
    }
    
}

enum BusLoad: String, Codable {
    case SeatsAvailable = "SEA"
    case StandingAvailable = "SDA"
    case LimitedStanding = "LSD"
}

enum BusFeature: String, Codable {
    case WheelchairAccessible = "WAB"
    case None = ""
}

enum BusType: String, Codable {
    case SingleDeck = "SD"
    case DoubleDeck = "DD"
    case Bendy = "BD"
}
