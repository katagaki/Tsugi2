//
//  BusStop.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import Foundation

class BusStop: Codable, Hashable, ObservableObject, Identifiable {

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

    init() {
        code = "46779"
        roadName = "Lorem Ipsum Dolor Street"
        description = "Opp Sample Bus Stop Secondary"
        latitude = 1.28459
        longitude = 103.83275
    }

    init(code: String, description: String?) {
        self.code = code
        self.description = description
    }

    enum CodingKeys: String, CodingKey {
        case code = "BusStopCode"
        case metadata = "odata.metadata"
        case arrivals = "Services"
        case roadName = "RoadName"
        case description = "Description"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }

    static func == (lhs: BusStop, rhs: BusStop) -> Bool {
        return lhs.code == rhs.code
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }

    func name() -> String {
        return description ?? localized("Shared.BusStop.Description.None")
    }

}
