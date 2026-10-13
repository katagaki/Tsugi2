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

    // Geocoding with MapKit
    var originalDescription: String?

    init() {
        code = "00000"
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
        case originalDescription = "OriginalDescription"
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
