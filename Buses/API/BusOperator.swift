//
//  BusOperator.swift
//  Buses
//
//  Created by 堅書 on 15/4/23.
//

import Foundation

enum BusOperator: String, Codable {
    case sbsTransit = "SBST"
    case smrt = "SMRT"
    case towerTransit = "TTS"
    case goAheadSingapore = "GAS"
    case unknown = "U"
}
