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
    private var _estimatedArrivalTime: String?
    private var _latitude: String?
    private var _longitude: String?
    private var _visitNumber: String?
    var load: BusLoad?
    var feature: BusFeature?
    var type: BusType?
    
    enum CodingKeys: String, CodingKey {
        case firstBusStopCode = "OriginCode"
        case lastBusStopCode = "DestinationCode"
        case _estimatedArrivalTime = "EstimatedArrival"
        case _latitude = "Latitude"
        case _longitude = "Longitude"
        case _visitNumber = "VisitNumber"
        case load = "Load"
        case feature = "Feature"
        case type = "Type"
    }
    
    func estimatedArrivalTime() -> Date? {
        return date(fromISO8601: _estimatedArrivalTime ?? "")
    }
    
    func latitude() -> Double? {
        return Double(_latitude ?? "0.0")
    }
    
    func longitude() -> Double? {
        return Double(_longitude ?? "0.0")
    }
    
    func visitNumber() -> Int? {
        return Int(_visitNumber ?? "0.0")
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
