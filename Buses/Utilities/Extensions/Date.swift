//
//  Date.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import Foundation

extension Date {

    func arrivalFormat(style: DateComponentsFormatter.UnitsStyle = .short) -> String {
        let interval: TimeInterval = self.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
        let seconds = NSInteger(interval) % 60
        let minutes = (NSInteger(interval) / 60) % 60
        if minutes == 0 {
            return (style == .short ?
                    localized("Shared.BusArrival.Arriving.Full") : localized("Shared.BusArrival.Arriving.Abbreviated"))
        } else if minutes <= 0 && seconds <= 0 {
            return (style == .short ?
                    localized("Shared.BusArrival.JustLeft.Full") : localized("Shared.BusArrival.JustLeft.Abbreviated"))
        } else {
            let formatter: DateComponentsFormatter = DateComponentsFormatter()
            formatter.unitsStyle = style
            formatter.allowedUnits = [.minute]
            return formatter.string(from: interval) ?? localized("Shared.BusArrival.NotInService")
        }
    }

}
