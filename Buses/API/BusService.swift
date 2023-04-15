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
    var direction: Int?
    var category: BusCategory?
    var originCode: String?
    var destinationCode: String?
    private var _amPeakFreq: String?
    private var _amOffpeakFreq: String?
    private var _pmPeakFreq: String?
    private var _pmOffpeakFreq: String?
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
        case _amPeakFreq = "AM_Peak_Freq"
        case _amOffpeakFreq = "AM_Offpeak_Freq"
        case _pmPeakFreq = "PM_Peak_Freq"
        case _pmOffpeakFreq = "PM_Offpeak_Freq"
        case loopDescription = "LoopDesc"
    }
    
    func amPeakStart() -> String? {
        if let freq = _amPeakFreq {
            return freq.components(separatedBy: "-")[0]
        }
        return nil
    }
    
    func amPeakEnd() -> String? {
        if let freq = _amPeakFreq {
            return freq.components(separatedBy: "-")[1]
        }
        return nil
    }
    
    func amOffpeakStart() -> String? {
        if let freq = _amOffpeakFreq {
            return freq.components(separatedBy: "-")[0]
        }
        return nil
    }
    
    func amOffpeakEnd() -> String? {
        if let freq = _amOffpeakFreq {
            return freq.components(separatedBy: "-")[1]
        }
        return nil
    }
    
    func pmPeakStart() -> String? {
        if let freq = _pmPeakFreq {
            return freq.components(separatedBy: "-")[0]
        }
        return nil
    }
    
    func pmPeakEnd() -> String? {
        if let freq = _pmPeakFreq {
            return freq.components(separatedBy: "-")[1]
        }
        return nil
    }
    
    func pmOffpeakStart() -> String? {
        if let freq = _pmOffpeakFreq {
            return freq.components(separatedBy: "-")[0]
        }
        return nil
    }
    
    func pmOffpeakEnd() -> String? {
        if let freq = _pmOffpeakFreq {
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
    case Express = "EXPRESS"
    case Feeder = "FEEDER"
    case Industrial = "INDUSTRIAL"
    case TownLink = "TOWNLINK"
    case Trunk = "TRUNK"
    case TwoTierFlatFee = "2 TIER FLAT FEE"
    case FlatFee110 = "FLAT FEE $1.10"
    case FlatFee190 = "FLAT FEE $1.90"
    case FlatFee350 = "FLAT FEE $3.50"
    case FlatFee380 = "FLAT FEE $3.80"
}
