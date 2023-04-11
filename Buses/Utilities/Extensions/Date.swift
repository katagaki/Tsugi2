//
//  Date.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import Foundation

extension Date {
    
    func arrivalFormat() -> String {
        let interval: TimeInterval = self.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
        let seconds = NSInteger(interval) % 60
        let minutes = (NSInteger(interval) / 60) % 60
        if minutes == 0 {
            return localized("Shared.BusArrival.Arriving")
        } else if minutes <= 0 && seconds <= 0 {
            return localized("Shared.BusArrival.JustLeft")
        } else {
            let formatter: DateComponentsFormatter = DateComponentsFormatter()
            formatter.unitsStyle = .short
            formatter.allowedUnits = [.minute]
            return formatter.string(from: interval) ?? localized("Shared.BusArrival.NotInService")
        }
    }
    
}
