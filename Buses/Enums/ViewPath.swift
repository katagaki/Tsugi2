//
//  ViewPath.swift
//  Buses
//
//  Created by シンジャスティン on 2023/08/30.
//

import Foundation

enum ViewPath: Hashable {
    case busService(BusService,
                    atLocation: String,
                    forBusStopCode: String)
    case busServiceNamed(String,
                    atLocation: String,
                    forBusStopCode: String)
    case busStop(BusStop)
    case mrtMap
    case fareCalculator
    case moreAppIcon
    case moreAttributions
}
