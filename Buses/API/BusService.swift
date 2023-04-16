//
//  BusService.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import Foundation

struct BusService: Codable, Hashable {

    // Shared variables
    var serviceNo: String
    var `operator`: BusOperator

    // BusArrivalv2 API
    var nextBus: BusArrivalInfo?
    var nextBus2: BusArrivalInfo?
    var nextBus3: BusArrivalInfo?

    // BusServices API
    var direction: BusRouteDirection?
    var category: BusCategory?
    var originCode: String?
    var destinationCode: String?
    var amPeakFreq: String?
    var amOffpeakFreq: String?
    var pmPeakFreq: String?
    var pmOffpeakFreq: String?
    var loopDescription: String?

    // Favorites data model
    var busStopCode: String? = ""

    init(serviceNo: String, operator: BusOperator) {
        self.serviceNo = serviceNo
        self.operator = `operator`
    }

    enum CodingKeys: String, CodingKey {
        case serviceNo = "ServiceNo"
        case `operator` = "Operator"
        case nextBus = "NextBus"
        case nextBus2 = "NextBus2"
        case nextBus3 = "NextBus3"
        case direction = "Direction"
        case category = "Category"
        case originCode = "OriginCode"
        case destinationCode = "DestinationCode"
        case amPeakFreq = "AM_Peak_Freq"
        case amOffpeakFreq = "AM_Offpeak_Freq"
        case pmPeakFreq = "PM_Peak_Freq"
        case pmOffpeakFreq = "PM_Offpeak_Freq"
        case loopDescription = "LoopDesc"
    }

    func amPeakStart() -> String? {
        if let freq = amPeakFreq {
            return freq.components(separatedBy: "-")[0]
        }
        return nil
    }

    func amPeakEnd() -> String? {
        if let freq = amPeakFreq {
            return freq.components(separatedBy: "-")[1]
        }
        return nil
    }

    func amOffpeakStart() -> String? {
        if let freq = amOffpeakFreq {
            return freq.components(separatedBy: "-")[0]
        }
        return nil
    }

    func amOffpeakEnd() -> String? {
        if let freq = amOffpeakFreq {
            return freq.components(separatedBy: "-")[1]
        }
        return nil
    }

    func pmPeakStart() -> String? {
        if let freq = pmPeakFreq {
            return freq.components(separatedBy: "-")[0]
        }
        return nil
    }

    func pmPeakEnd() -> String? {
        if let freq = pmPeakFreq {
            return freq.components(separatedBy: "-")[1]
        }
        return nil
    }

    func pmOffpeakStart() -> String? {
        if let freq = pmOffpeakFreq {
            return freq.components(separatedBy: "-")[0]
        }
        return nil
    }

    func pmOffpeakEnd() -> String? {
        if let freq = pmOffpeakFreq {
            return freq.components(separatedBy: "-")[1]
        }
        return nil
    }

    mutating func updateNextBuses(with busService: BusService) {
        nextBus = busService.nextBus
        nextBus2 = busService.nextBus2
        nextBus3 = busService.nextBus3
    }

}

enum BusCategory: String, Codable {
    case express = "EXPRESS"
    case feeder = "FEEDER"
    case industrial = "INDUSTRIAL"
    case townLink = "TOWNLINK"
    case trunk = "TRUNK"
    case twoTierFlatFee = "2 TIER FLAT FEE"
    case flatFee110 = "FLAT FEE $1.10"
    case flatFee190 = "FLAT FEE $1.90"
    case flatFee350 = "FLAT FEE $3.50"
    case flatFee380 = "FLAT FEE $3.80"
}
