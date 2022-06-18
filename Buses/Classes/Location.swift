//
//  Location.swift
//  Buses
//
//  Created by Justin Xin on 2022/06/18.
//

import Foundation

class Location {
    var busStopCode: String
    var nickname: String
    var usesLiveBusStopData: Bool
    
    init(busStopCode: String, nickname: String = "", usesLiveBusStopData: Bool = true) {
        self.busStopCode = busStopCode
        self.nickname = nickname
        self.usesLiveBusStopData = usesLiveBusStopData
    }
}
