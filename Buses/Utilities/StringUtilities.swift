//
//  StringUtilities.swift
//  Buses
//
//  Created by 堅書 on 2022/04/11.
//

import Foundation

func localized(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

func getArrivalText(arrivalTime: Date?) -> String {
    if let arrivalTime = arrivalTime {
        return arrivalTimeTo(date: arrivalTime)
    } else {
        return "N/A"
    }
}
