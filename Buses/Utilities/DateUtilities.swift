//
//  DateUtilities.swift
//  Buses
//
//  Created by 堅書 on 2022/04/09.
//

import Foundation

func date(fromISO8601 dateString: String) -> Date? {
    let formatter: DateFormatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return formatter.date(from: dateString)
}

func arrivalTimeTo(date: Date?) -> String {
    if let date = date {
        let interval: TimeInterval = date.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
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
    } else {
        return localized("Shared.BusArrival.NotInService")
    }
}
