//
//  BusServiceList.swift
//  Buses
//
//  Created by 堅書 on 2023/04/22.
//

import Foundation

class BusServiceList: Codable, Hashable, ObservableObject, Identifiable {

    // BusServices API
    var metadata: String
    var busServices: [BusService]
    var combinedBusServiceNos: String?

    init() {
        metadata = "created.from.init"
        busServices = []
        combinedBusServiceNos = busServices.reduce("", { partialResult, busService in
            partialResult + busService.serviceNo
        })
    }

    enum CodingKeys: String, CodingKey {
        case metadata = "odata.metadata"
        case busServices = "value"
    }

    static func == (lhs: BusServiceList, rhs: BusServiceList) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(combinedBusServiceNos!)
    }

}
