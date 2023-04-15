//
//  BusOperator.swift
//  Buses
//
//  Created by 堅書 on 15/4/23.
//

import Foundation

enum BusOperator: String, Codable {
    case SBSTransit = "SBST"
    case SMRT = "SMRT"
    case TowerTransit = "TTS"
    case GoAheadSingapore = "GAS"
    case Unknown = "U"
}
