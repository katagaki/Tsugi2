//
//  BABusService.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import Foundation

struct BABusService: Codable, Hashable {
    
    var serviceNo: String
    var `operator`: BusOperator
    var nextBus: BABusOnRoad
    var nextBus2: BABusOnRoad
    var nextBus3: BABusOnRoad
    
    enum CodingKeys: String, CodingKey {
        case serviceNo = "ServiceNo"
        case `operator` = "Operator"
        case nextBus = "NextBus"
        case nextBus2 = "NextBus2"
        case nextBus3 = "NextBus3"
    }
    
}

enum BusOperator: String, Codable {
    case SBSTransit = "SBST"
    case SMRT = "SMRT"
    case TowerTransit = "TTS"
    case GoAheadSingapore = "GAS"
}
