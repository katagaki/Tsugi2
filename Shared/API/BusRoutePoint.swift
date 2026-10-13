//
//  BusRoutePoint.swift
//  Buses
//
//  Created by 堅書 on 15/4/23.
//

import Foundation

class BusRoutePoint: Codable, Hashable, ObservableObject, Identifiable {

    var serviceNo: String
    var `operator`: BusOperator
    var direction: BusRouteDirection
    var stopSequence: Int
    var stopCode: String
    var distance: Double
    var weekdayFirstBusTime: String
    var weekdayLastBusTime: String
    var saturdayFirstBusTime: String
    var saturdayLastBusTime: String
    var sundayFirstBusTime: String
    var sundayLastBusTime: String

    init(serviceNo: String, operator: BusOperator, direction: BusRouteDirection,
         stopSequence: Int, stopCode: String) {
        self.serviceNo = serviceNo
        self.operator = `operator`
        self.direction = direction
        self.stopSequence = stopSequence
        self.stopCode = stopCode
        self.distance = 0.0
        self.weekdayFirstBusTime = ""
        self.weekdayLastBusTime = ""
        self.saturdayFirstBusTime = ""
        self.saturdayLastBusTime = ""
        self.sundayFirstBusTime = ""
        self.sundayLastBusTime = ""
    }

    enum CodingKeys: String, CodingKey {
        case serviceNo = "ServiceNo"
        case `operator` = "Operator"
        case direction = "Direction"
        case stopSequence = "StopSequence"
        case stopCode = "BusStopCode"
        case distance = "Distance"
        case weekdayFirstBusTime = "WD_FirstBus"
        case weekdayLastBusTime = "WD_LastBus"
        case saturdayFirstBusTime = "SAT_FirstBus"
        case saturdayLastBusTime = "SAT_LastBus"
        case sundayFirstBusTime = "SUN_FirstBus"
        case sundayLastBusTime = "SUN_LastBus"
    }

    static func == (lhs: BusRoutePoint, rhs: BusRoutePoint) -> Bool {
        return lhs.serviceNo == rhs.serviceNo &&
        lhs.stopSequence == rhs.stopSequence
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine("\(serviceNo).\(stopSequence)")
    }

}
