//
//  BusArrivalInfo.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import Foundation

struct BusArrivalInfo: Codable, Hashable {

    var firstBusStopCode: String?
    var lastBusStopCode: String?
    var estimatedArrivalTime: String?
    var latitude: String?
    var longitude: String?
    var visitNumber: String?
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

    func estimatedArrivalTimeAsDate() -> Date? {
        return estimatedArrivalTime?.toDateFromISO8601()
    }

    func latitudeAsDouble() -> Double? {
        return Double(latitude ?? "0.0")
    }

    func longitudeAsDouble() -> Double? {
        return Double(longitude ?? "0.0")
    }

    func visitNumberAsEnum() -> BusRouteDirection {
        if (visitNumber?.toInt() ?? 0) % 2 == 0 {
            return .backward
        } else {
            return .forward
        }
    }

}

enum BusLoad: String, Codable {
    case seatsAvailable = "SEA"
    case standingAvailable = "SDA"
    case limitedStanding = "LSD"
    case notApplicable = ""
}

enum BusFeature: String, Codable {
    case wheelchairAccessible = "WAB"
    case none = ""
}

enum BusType: String, Codable {
    case singleDeck = "SD"
    case doubleDeck = "DD"
    case bendy = "BD"
    case notApplicable = ""
}
