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
            formatter.allowedUnits = [.minute]
            formatter.unitsStyle = style
            var formattedString: String?
            autoreleasepool {
                // TODO: Fix memory leak caused by DateFormatter
                // https://github.com/apple/swift/issues/56085
                formattedString = formatter.string(from: interval)
            }
            return formattedString ?? localized("Shared.BusArrival.NotInService")
        }
    }

}
