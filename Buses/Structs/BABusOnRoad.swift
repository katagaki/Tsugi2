//
//  BABusOnRoad.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import Foundation

struct BABusOnRoad: Codable, Hashable {
    
    var firstBusStopCode: String?
    var lastBusStopCode: String?
    var estimatedArrivalTime: String? // Should convert to Date
    var latitude: String? // Should convert to Double
    var longitude: String? // Should convert to Double
    var visitNumber: String? // Should convert to Int
    var load: BusLoad?
    var feature: BusFeature?
    var type: BusType?
    
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
    case NotApplicable = ""
}

enum BusFeature: String, Codable {
    case WheelchairAccessible = "WAB"
    case None = ""
}

enum BusType: String, Codable {
    case SingleDeck = "SD"
    case DoubleDeck = "DD"
    case Bendy = "BD"
    case NotApplicable = ""
}
